class CreateAccounts < ActiveRecord::Migration[ENV['MIGRATION_VESRION']]
  def change
    create_table :accounts do |t|
      t.column :name, :string
      t.column :subdomain, :string
      t.column :domain, :string

      t.timestamps
    end
  end
end
