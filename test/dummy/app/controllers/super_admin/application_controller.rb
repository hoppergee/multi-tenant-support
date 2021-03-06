module SuperAdmin
  class ApplicationController < ::ApplicationController
    before_action :allow_read_across_tenant
    skip_before_action :super_admin_redirect
    skip_before_action :set_current_tenant_account

    private

    def allow_read_across_tenant
      MultiTenantSupport.allow_read_across_tenant
    end

  end
end