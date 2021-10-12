require 'active_support'

module MultiTenantSupport

  # Scoped and proteced
  PROTECTED = 1

  # Scoped and protected except read across tenant
  PROTECTED_EXCEPT_READ = 2

  # Scoped but unprotected
  UNPROTECTED = 3

  # This class is for internal usage only
  class Current < ActiveSupport::CurrentAttributes
    attribute :tenant_account,
              :protection_state

    def protection_state
      attributes[:protection_state] ||= PROTECTED
    end
  end
end