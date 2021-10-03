class AddCountryIdToUsers < ActiveRecord::Migration[6.1]
  def change
    add_reference :users, :country
  end
end
