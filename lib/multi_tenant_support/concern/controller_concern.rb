module MultiTenantSupport

  module ControllerConcern
    extend ActiveSupport::Concern

    included do
      include ViewHelper

      before_action :set_current_tenant_account

      private

      def set_current_tenant_account
        tenant_account = find_current_tenant_account
        MultiTenantSupport::Current.tenant_account = tenant_account
        instance_variable_set("@#{MultiTenantSupport.current_tenant_account_method}", tenant_account)
      end

      # A user can override this method, if he need a customize way
      def find_current_tenant_account
        MultiTenantSupport::FindTenantAccount.call(
          subdomains: request.subdomains,
          domain: request.domain
        )
      end
    end
  end

  module ViewHelper
    extend ActiveSupport::Concern

    included do
      define_method(MultiTenantSupport.current_tenant_account_method) do
        instance_variable_get("@#{MultiTenantSupport.current_tenant_account_method}")
      end
    end
  end
end

ActiveSupport.on_load(:action_controller) do |base|
  base.include MultiTenantSupport::ControllerConcern
end

ActiveSupport.on_load(:action_view) do |base|
  base.include MultiTenantSupport::ViewHelper
end