class CreateExternalApiRateLimits < ActiveRecord::Migration[8.1]
  def change
    create_table :external_api_rate_limits do |t|
      t.string :name, null: false
      t.float :min_interval_seconds, null: false
      t.datetime :last_requested_at

      t.timestamps

      t.index :name, unique: true
    end
  end
end
