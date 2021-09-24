class CreateAccounts < ActiveRecord::Migration[6.1]
  def change
    create_table :accounts do |t|
      t.column :name, :string
      t.column :subdomain, :string
      t.column :domain, :string

      t.timestamps
    end
  end
end
