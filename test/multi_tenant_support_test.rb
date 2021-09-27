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

    fisher_mante = accounts(:fisher_mante)
    MultiTenantSupport::Current.tenant_account = fisher_mante
    assert_equal fisher_mante, MultiTenantSupport.current_tenant
  end

  test ".under_tenant" do
    fisher_mante = accounts(:fisher_mante)
    MultiTenantSupport::Current.tenant_account = fisher_mante
   
    beer_stark = accounts(:beer_stark)
    MultiTenantSupport.under_tenant beer_stark do
      assert_equal beer_stark, MultiTenantSupport.current_tenant
    end

    assert_equal fisher_mante, MultiTenantSupport.current_tenant
  end

  test '.default_tenant_scope_on?' do
    MultiTenantSupport::Current.default_tenant_scope_on = nil
    refute MultiTenantSupport.default_tenant_scope_on?

    MultiTenantSupport::Current.default_tenant_scope_on = true
    assert MultiTenantSupport.default_tenant_scope_on?

    MultiTenantSupport::Current.default_tenant_scope_on = false
    refute MultiTenantSupport.default_tenant_scope_on?
  end

end
