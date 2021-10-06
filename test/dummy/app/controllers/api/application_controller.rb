module Api
  class ApplicationController < ActionController::API
    before_action :check_current_tenant
    rescue_from MultiTenantSupport::MissingTenantError, with: :handle_error

    private

    def check_current_tenant
      raise MultiTenantSupport::MissingTenantError.new("Wrong domain or subdomain") unless current_tenant_account
    end

    def handle_error(error)
      render json: {
        error: error
      }
    end
  end
end
