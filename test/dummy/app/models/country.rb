class Country < ApplicationRecord
  has_many :users, dependent: :destroy
end
