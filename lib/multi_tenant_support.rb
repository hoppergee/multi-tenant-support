require "multi_tenant_support/version"
require "multi_tenant_support/configuration"
require "multi_tenant_support/current"
require "multi_tenant_support/find_tenant_account"
require "multi_tenant_support/concern/controller_concern"
require "multi_tenant_support/concern/model_concern"

module MultiTenantSupport

  module_function

  def configure
    yield configuration
  end

  def configuration
    @configuration ||= Configuration.new
  end

  def current_tenant_account_method
    configuration.current_tenant_account_method
  end

  def current_tenant
    Current.tenant_account
  end

  def under_tenant(tenant_account, &block)
    raise ArgumentError, "block is missing" if block.nil?

    Current.set(tenant_account: tenant_account) do
      yield
    end
  end

  def default_tenant_scope_on?
    Current.default_tenant_scope_on
  end

end
