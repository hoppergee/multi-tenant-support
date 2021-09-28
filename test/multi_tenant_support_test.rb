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

  test '.default_scope_on?' do
    MultiTenantSupport::Current.default_scope_off = nil
    assert MultiTenantSupport.default_scope_on?

    MultiTenantSupport::Current.default_scope_off = true
    refute MultiTenantSupport.default_scope_on?

    MultiTenantSupport::Current.default_scope_off = false
    assert MultiTenantSupport.default_scope_on?
  end

  test ".turn_default_scope_on and .turn_default_scope_off" do
    MultiTenantSupport::Current.default_scope_off = nil
    MultiTenantSupport.turn_default_scope_on
    assert MultiTenantSupport.default_scope_on?

    MultiTenantSupport.turn_default_scope_off
    refute MultiTenantSupport.default_scope_on?
  end

  test ".turn_default_scope_on - accept block" do
    MultiTenantSupport::Current.default_scope_off = true
    refute MultiTenantSupport.default_scope_on?

    MultiTenantSupport.turn_default_scope_on do
      assert MultiTenantSupport.default_scope_on?
    end

    refute MultiTenantSupport.default_scope_on?
  end

  test ".turn_default_scope_off - accept block" do
    MultiTenantSupport::Current.default_scope_off = false
    assert MultiTenantSupport.default_scope_on?

    MultiTenantSupport.turn_default_scope_off do
      refute MultiTenantSupport.default_scope_on?
    end

    assert MultiTenantSupport.default_scope_on?
  end

end
