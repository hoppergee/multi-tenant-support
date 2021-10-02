require "test_helper"

class MultiTenantSupportTest < ActiveSupport::TestCase
  test "it has a version number" do
    assert MultiTenantSupport::VERSION
  end

  test ".configure" do
    MultiTenantSupport.configure do
      model do |config|
        config.tenant_account_class_name = 'Account'
        config.tenant_account_primary_key = :id
      end

      controller do |config|
        config.current_tenant_account_method = :current_tenant_account
      end

      app do |config|
        config.excluded_subdomains = ['www']
        config.host = 'example.com'
      end
    end

    assert_equal :id, MultiTenantSupport.model.tenant_account_primary_key
    assert_equal 'Account', MultiTenantSupport.model.tenant_account_class_name
    assert_equal :account_id, MultiTenantSupport.model.default_foreign_key
    assert_equal :current_tenant_account, MultiTenantSupport.controller.current_tenant_account_method
    assert_equal ['www'], MultiTenantSupport.app.excluded_subdomains
    assert_equal 'example.com', MultiTenantSupport.app.host
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
