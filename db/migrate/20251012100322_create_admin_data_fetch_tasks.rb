class CreateAdminDataFetchTasks < ActiveRecord::Migration[8.0]
  def change
    create_table :admin_data_fetch_tasks do |t|
      t.references :chat, null: true, foreign_key: { to_table: :ai_chats }
      t.references :target, polymorphic: true, null: false
      t.string :type, null: false
      t.string :status, null: false
      t.json :input_data
      t.json :fetched_data
      t.string :fetch_error_details
      t.timestamps
    end
  end
end
