module Api
  class UsersController < ApplicationController
    def index
      render json: {
        tenant: current_tenant_account.name,
        domain: current_tenant_account.domain,
        subdomain: current_tenant_account.subdomain
      }
    end
  end
end