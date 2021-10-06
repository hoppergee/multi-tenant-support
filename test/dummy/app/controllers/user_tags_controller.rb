class UserTagsController < ApplicationController
  def index
  end

  private

  def find_current_tenant_account
    Account.find_by(domain: request.domain)
  end
end