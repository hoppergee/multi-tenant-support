class ApplicationController < ActionController::Base
  before_action :super_admin_redirect

  private

  def super_admin_redirect
    return if current_tenant_account

    redirect_to super_admin_dashboard_path
  end
end
