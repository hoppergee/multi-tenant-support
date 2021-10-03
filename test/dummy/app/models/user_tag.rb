class UserTag < ApplicationRecord
  belongs_to_tenant :account
  belongs_to :user
  belongs_to :tag
end
