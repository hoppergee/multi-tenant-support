class AddCountryIdToUsers < ActiveRecord::Migration[ENV['MIGRATION_VESRION']]
  def change
    add_reference :users, :country
  end
end
