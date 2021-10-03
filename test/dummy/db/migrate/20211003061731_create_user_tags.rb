class CreateUserTags < ActiveRecord::Migration[6.1]
  def change
    create_table :user_tags do |t|
      t.belongs_to :account, null: false
      t.belongs_to :user
      t.belongs_to :tag

      t.timestamps
    end
  end
end
