# frozen_string_literal: true

class UpgradeRubyLlmTo21 < ActiveRecord::Migration[8.1]
  USAGE_OPERATIONS = %w[
    chat embedding moderation image speech transcription ocr rerank judgment video research
  ].freeze

  def change
    create_mcp_credentials
    add_tool_call_columns
    add_usage_columns
    widen_usage_operations
    add_column :ai_messages, :cache_ttl, :string unless column_exists?(:ai_messages, :cache_ttl)
    create_provider_files
  end

  private

  def create_mcp_credentials
    return if table_exists?(:ruby_llm_mcp_credentials)

    create_table :ruby_llm_mcp_credentials, id: :bigint do |t|
      t.references :owner, polymorphic: true, type: :bigint
      t.string :key, null: false
      t.text :data
      t.timestamps

      t.index :key, unique: true
    end
  end

  def add_tool_call_columns
    unless column_exists?(:ruby_llm_tool_calls, :mcp_state)
      if column_exists?(:ruby_llm_tool_calls, :pending_input)
        rename_column :ruby_llm_tool_calls, :pending_input, :mcp_state
      else
        add_column :ruby_llm_tool_calls, :mcp_state, :json
      end
    end

    return if column_exists?(:ruby_llm_tool_calls, :mcp_result)

    add_column :ruby_llm_tool_calls, :mcp_result, :json
  end

  def add_usage_columns
    add_column :ruby_llm_usages, :server_tool_use, :json unless column_exists?(:ruby_llm_usages, :server_tool_use)

    if columns(:ruby_llm_usages).any? { |column| column.name == 'chat_id' && !column.null }
      change_column_null :ruby_llm_usages, :chat_type, true
      change_column_null :ruby_llm_usages, :chat_id, true
    end

    return if column_exists?(:ruby_llm_usages, :owner_id)

    add_reference :ruby_llm_usages, :owner, polymorphic: true, type: :bigint, index: true
  end

  def widen_usage_operations
    reversible do |direction|
      direction.up do
        constraint = operation_check_constraint
        next unless constraint
        next if USAGE_OPERATIONS.all? { |operation| constraint.expression.include?("'#{operation}'") }

        remove_check_constraint :ruby_llm_usages, name: constraint.name
        add_check_constraint :ruby_llm_usages, usage_operations_sql
      end
    end
  end

  def create_provider_files
    return if table_exists?(:ruby_llm_provider_files)

    create_table :ruby_llm_provider_files, id: :bigint do |t|
      t.string :blob_key, null: false
      t.string :provider, null: false
      t.string :account, null: false
      t.text :file_id, null: false
      t.datetime :expires_at
      t.timestamps

      t.index %i[blob_key provider account], unique: true, name: 'index_ruby_llm_provider_files_uniqueness'
    end
  end

  def operation_check_constraint
    check_constraints(:ruby_llm_usages).find do |constraint|
      constraint.expression.include?('operation')
    end
  end

  def usage_operations_sql
    quoted = USAGE_OPERATIONS.map { |operation| "'#{operation}'" }.join(', ')
    "operation IN (#{quoted})"
  end
end
