class CreateTags < ActiveRecord::Migration[ENV['MIGRATION_VESRION']]
  def change
    create_table :tags do |t|
      t.string :name

      t.timestamps
    end
  end
end
