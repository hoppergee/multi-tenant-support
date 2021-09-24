module MultiTenantSupport
  module ControllerConcern
    extend ActiveSupport::Concern

    included do
      helper_method MultiTenantSupport.current_tenant_account_method

      before_action :set_current_tenant_account

      private

      define_method(MultiTenantSupport.current_tenant_account_method) do
        instance_variable_get("@#{MultiTenantSupport.current_tenant_account_method}")
      end

      def set_current_tenant_account
        tenant_account_class = MultiTenantSupport.tenant_account_class
        tenant_account = tenant_account_class.constantize.find_tenant_account(
          subdomains: request.subdomains,
          domain: request.domain
        )
        MultiTenantSupport::Current.tenant_account = tenant_account
        instance_variable_set("@#{MultiTenantSupport.current_tenant_account_method}", tenant_account)
      end
    end
  end
end

ActiveSupport.on_load(:action_controller) do |base|
  base.include MultiTenantSupport::ControllerConcern
end