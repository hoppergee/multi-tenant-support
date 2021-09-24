require "multi_tenant_support/version"
require "multi_tenant_support/configuration"
require "multi_tenant_support/current"
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

  def tenant_account_class
    configuration.tenant_account_class
  end

  def current_tenant_account_method
    configuration.current_tenant_account_method
  end

end
