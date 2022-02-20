class CreateCountries < ActiveRecord::Migration[ENV['MIGRATION_VESRION']]
  def change
    create_table :countries do |t|
      t.string :code
      t.string :name

      t.timestamps
    end
  end
end
