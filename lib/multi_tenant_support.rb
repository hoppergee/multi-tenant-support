require "multi_tenant_support/version"
require "multi_tenant_support/errors"
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

  def current_tenant_id
    Current.tenant_account.send(configuration.primary_key)
  end

  def under_tenant(tenant_account, &block)
    raise ArgumentError, "block is missing" if block.nil?

    Current.set(tenant_account: tenant_account) do
      yield
    end
  end

  def default_scope_on?
    !Current.default_scope_off
  end

  def turn_default_scope_on
    if block_given?
      Current.set(default_scope_off: false) do
        yield
      end
    else
      Current.default_scope_off = false
    end
  end

  def turn_default_scope_off
    if block_given?
      Current.set(default_scope_off: true) do
        yield
      end
    else
      Current.default_scope_off = true
    end
  end

end
