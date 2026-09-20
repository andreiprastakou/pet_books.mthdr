# frozen_string_literal: true

# This app never had a 1.16 Model table: chats/messages stored the provider
# model name in a string `model_id` column. RubyLLM 2.0's upgrade generator
# expects a Model table and an integer FK on chats. Normalize to that shape
# before the generated prepare/backfill/finish migrations run.
class PrepareRubyLlmV2LegacySchema < ActiveRecord::Migration[8.1]
  class LegacyModel < ActiveRecord::Base
    self.table_name = 'models'
    self.inheritance_column = :_type_disabled
  end

  class LegacyChat < ActiveRecord::Base
    self.table_name = 'ai_chats'
    self.inheritance_column = :_type_disabled
  end

  def up
    create_models_table
    convert_chat_model_ids_to_foreign_keys
    rename_tool_calls_table
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end

  private

  def create_models_table
    return if table_exists?(:models)

    create_table :models do |t|
      t.string :model_id, null: false
      t.string :name, null: false
      t.string :provider, null: false
      t.string :family
      t.datetime :model_created_at
      t.integer :context_window
      t.integer :max_output_tokens
      t.date :knowledge_cutoff
      t.json :modalities, default: {}
      t.json :capabilities, default: []
      t.json :pricing, default: {}
      t.json :metadata, default: {}
      t.timestamps
    end

    add_index :models, %i[provider model_id], unique: true
    add_index :models, :provider
  end

  def convert_chat_model_ids_to_foreign_keys
    return unless column_exists?(:ai_chats, :model_id)
    return if connection.columns(:ai_chats).find { |c| c.name == 'model_id' }.type != :string

    rename_column :ai_chats, :model_id, :legacy_model_id
    add_reference :ai_chats, :model, foreign_key: true, index: true

    LegacyChat.reset_column_information
    LegacyModel.reset_column_information

    LegacyChat.where.not(legacy_model_id: [nil, '']).find_each do |chat|
      model = LegacyModel.find_or_create_by!(provider: 'openai', model_id: chat.legacy_model_id) do |record|
        record.name = chat.legacy_model_id
      end
      chat.update_columns(model_id: model.id)
    end

    remove_column :ai_chats, :legacy_model_id
  end

  def rename_tool_calls_table
    return unless table_exists?(:ai_tool_calls)
    return if table_exists?(:tool_calls)

    if foreign_key_exists?(:ai_messages, :ai_tool_calls, column: :tool_call_id)
      remove_foreign_key :ai_messages, :ai_tool_calls
    end

    rename_table :ai_tool_calls, :tool_calls
    add_foreign_key :ai_messages, :tool_calls, column: :tool_call_id
  end
end
