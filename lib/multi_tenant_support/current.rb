module MultiTenantSupport
  class Current < ActiveSupport::CurrentAttributes
    attribute :tenant_account,
              :default_tenant_scope_on
  end
end