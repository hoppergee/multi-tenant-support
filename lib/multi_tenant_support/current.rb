module MultiTenantSupport
  class Current < ActiveSupport::CurrentAttributes
    attribute :tenant_account
  end
end