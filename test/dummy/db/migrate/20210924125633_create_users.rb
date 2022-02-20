class CreateUsers < ActiveRecord::Migration[ENV['MIGRATION_VESRION']]
  def change
    create_table :users do |t|
      t.string :name
      t.string :email, null: false
      t.integer :account_id

      t.timestamps
    end

    add_index :users, :email, unique: true
  end
end
