require "test_helper"

class MultiTenantSupport::ConfigurationTest < ActiveSupport::TestCase

  setup do
    @configuration = MultiTenantSupport::Configuration.new
  end

  test "#tenant_account_class and #tenant_account_class=" do
    assert_raise "tenant_account_class is missing" do
      @configuration.tenant_account_class
    end

    @configuration.tenant_account_class = 'Account'
    assert_equal 'Account', @configuration.tenant_account_class
  end

  test "#primary_key and #primary_key=" do
    assert_equal :id, @configuration.primary_key

    @configuration.primary_key = :uuid
    assert_equal :uuid, @configuration.primary_key
  end

  test "#foreign_key and #foreign_key=" do
    @configuration.tenant_account_class = 'Account'

    assert_equal :account_id, @configuration.foreign_key

    @configuration.foreign_key = :a_id
    assert_equal :a_id, @configuration.foreign_key
  end

  test "#excluded_subdomains and #excluded_subdomains=" do
    assert_equal [], @configuration.excluded_subdomains

    @configuration.excluded_subdomains = ["www"]
    assert_equal ["www"], @configuration.excluded_subdomains
  end

  test "#current_tenant_account_method and #current_tenant_account_method=" do
    assert_equal :current_tenant_account, @configuration.current_tenant_account_method

    @configuration.current_tenant_account_method = :current_account
    assert_equal :current_account, @configuration.current_tenant_account_method
  end

  test "#host and #host=" do
    assert_raise "host is missing" do
      @configuration.host
    end

    @configuration.host = "example.com"
    assert_equal "example.com", @configuration.host
  end

end