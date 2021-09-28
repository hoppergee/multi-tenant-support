require "test_helper"

class MultiTenantSupportTest < ActiveSupport::TestCase
  test "it has a version number" do
    assert MultiTenantSupport::VERSION
  end

  test ".configure" do
    MultiTenantSupport.configure do |config|
      config.tenant_account_class = 'Account'
      config.primary_key = :id
      config.excluded_subdomains = ['www']
      config.current_tenant_account_method = :current_tenant_account
      config.host = 'example.com'
    end

    assert_equal :current_tenant_account, MultiTenantSupport.current_tenant_account_method

    configuration = MultiTenantSupport.configuration
    assert_equal :id, configuration.primary_key
    assert_equal ['www'], configuration.excluded_subdomains
    assert_equal 'example.com', configuration.host
  end

  test ".tenant_account" do
    MultiTenantSupport::Current.tenant_account = nil
    assert MultiTenantSupport.current_tenant.nil?

    facebook = accounts(:facebook)
    MultiTenantSupport::Current.tenant_account = facebook
    assert_equal facebook, MultiTenantSupport.current_tenant
  end

  test ".under_tenant" do
    facebook = accounts(:facebook)
    MultiTenantSupport::Current.tenant_account = facebook
   
    amazon = accounts(:amazon)
    MultiTenantSupport.under_tenant amazon do
      assert_equal amazon, MultiTenantSupport.current_tenant
    end

    assert_equal facebook, MultiTenantSupport.current_tenant
  end

  test '.disallow_read_across_tenant?' do
    MultiTenantSupport::Current.allow_read_across_tenant = nil
    assert MultiTenantSupport.disallow_read_across_tenant?

    MultiTenantSupport::Current.allow_read_across_tenant = true
    refute MultiTenantSupport.disallow_read_across_tenant?

    MultiTenantSupport::Current.allow_read_across_tenant = false
    assert MultiTenantSupport.disallow_read_across_tenant?
  end

  test ".disallow_read_across_tenant and .allow_read_across_tenant" do
    MultiTenantSupport::Current.allow_read_across_tenant = nil
    MultiTenantSupport.disallow_read_across_tenant
    assert MultiTenantSupport.disallow_read_across_tenant?

    MultiTenantSupport.allow_read_across_tenant
    refute MultiTenantSupport.disallow_read_across_tenant?
  end

  test ".disallow_read_across_tenant - accept block" do
    MultiTenantSupport::Current.allow_read_across_tenant = true
    refute MultiTenantSupport.disallow_read_across_tenant?

    MultiTenantSupport.disallow_read_across_tenant do
      assert MultiTenantSupport.disallow_read_across_tenant?
    end

    refute MultiTenantSupport.disallow_read_across_tenant?
  end

  test ".allow_read_across_tenant - accept block" do
    MultiTenantSupport::Current.allow_read_across_tenant = false
    assert MultiTenantSupport.disallow_read_across_tenant?

    MultiTenantSupport.allow_read_across_tenant do
      refute MultiTenantSupport.disallow_read_across_tenant?
    end

    assert MultiTenantSupport.disallow_read_across_tenant?
  end

end
