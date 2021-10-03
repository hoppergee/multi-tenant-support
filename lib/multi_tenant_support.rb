require "multi_tenant_support/version"
require 'multi_tenant_support/railtie'
require "multi_tenant_support/errors"
require "multi_tenant_support/config/app"
require "multi_tenant_support/config/controller"
require "multi_tenant_support/config/model"
require "multi_tenant_support/current"
require "multi_tenant_support/find_tenant_account"
require "multi_tenant_support/concern/controller_concern"
require "multi_tenant_support/concern/model_concern"

module MultiTenantSupport

  module_function

  def configure(&block)
    instance_eval(&block)
  end

  def current_tenant
    Current.tenant_account
  end

  def current_tenant_id
    Current.tenant_account&.send(model.tenant_account_primary_key)
  end

  def under_tenant(tenant_account, &block)
    raise ArgumentError, "block is missing" if block.nil?

    Current.set(tenant_account: tenant_account) do
      yield
    end
  end

  def disallow_read_across_tenant?
    !Current.allow_read_across_tenant
  end

  def disallow_read_across_tenant
    if block_given?
      Current.set(allow_read_across_tenant: false) do
        yield
      end
    else
      Current.allow_read_across_tenant = false
    end
  end

  def allow_read_across_tenant
    if block_given?
      Current.set(allow_read_across_tenant: true) do
        yield
      end
    else
      Current.allow_read_across_tenant = true
    end
  end

end
