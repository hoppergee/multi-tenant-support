require 'active_support'

module MultiTenantSupport
  class Current < ActiveSupport::CurrentAttributes
    attribute :tenant_account,
              :allow_read_across_tenant
  end
end