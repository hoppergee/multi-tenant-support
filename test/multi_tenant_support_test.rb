require "test_helper"

class MultiTenantSupportTest < ActiveSupport::TestCase
  test "it has a version number" do
    assert MultiTenantSupport::VERSION
  end

  test ".configure" do
    MultiTenantSupport.configure do |config|
      config.tenant_account_class = 'Account'
      config.primary_key = :id
      config.excluded_models = ['Account']
      config.excluded_subdomains = ['www']
      config.current_tenant_account_method = :current_tenant_account
      config.host = 'example.com'
    end

    assert_equal 'Account', MultiTenantSupport.tenant_account_class
    assert_equal :current_tenant_account, MultiTenantSupport.current_tenant_account_method

    configuration = MultiTenantSupport.configuration
    assert_equal :id, configuration.primary_key
    assert_equal ['Account'], configuration.excluded_models
    assert_equal ['www'], configuration.excluded_subdomains
    assert_equal 'example.com', configuration.host
  end

end
