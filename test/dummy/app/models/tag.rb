class Tag < ApplicationRecord
  has_many :user_tags
  has_many :users, through: :user_tags
end
