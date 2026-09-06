class CreateExternalIdentitiesAndDataFetches < ActiveRecord::Migration[8.1]
  def change
    create_table :external_identities do |t|
      t.string :owner_type, null: false
      t.integer :owner_id, null: false
      t.integer :external_resource, null: false
      t.string :identificator
      t.string :url

      t.timestamps

      t.index %i[owner_type owner_id]
      t.index %i[external_resource identificator], unique: true
    end

    create_table :external_data_fetches do |t|
      t.references :external_identity, null: false, foreign_key: true
      t.json :data

      t.timestamps
    end
  end
end
