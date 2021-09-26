class User < ApplicationRecord
  belongs_to_tenant :account
end
