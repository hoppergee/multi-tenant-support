class CreateUserTags < ActiveRecord::Migration[ENV['MIGRATION_VESRION']]
  def change
    create_table :user_tags do |t|
      t.belongs_to :account, null: false
      t.belongs_to :user
      t.belongs_to :tag

      t.timestamps
    end
  end
end
