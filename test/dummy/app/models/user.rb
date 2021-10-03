class User < ApplicationRecord
  belongs_to_tenant :account
  has_many :user_tags
  has_many :tags, through: :user_tags
end
