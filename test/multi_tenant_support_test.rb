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

  test '.full_protected?' do
    MultiTenantSupport::Current.tenant_account = nil

    MultiTenantSupport::Current.protection_state = MultiTenantSupport::PROTECTED
    assert MultiTenantSupport.full_protected?
    MultiTenantSupport::Current.protection_state = MultiTenantSupport::PROTECTED_EXCEPT_READ
    refute MultiTenantSupport.full_protected?
    MultiTenantSupport::Current.protection_state = MultiTenantSupport::UNPROTECTED
    refute MultiTenantSupport.full_protected?

    MultiTenantSupport::Current.tenant_account = amazon

    MultiTenantSupport::Current.protection_state = MultiTenantSupport::PROTECTED
    assert MultiTenantSupport.full_protected?
    MultiTenantSupport::Current.protection_state = MultiTenantSupport::PROTECTED_EXCEPT_READ
    assert MultiTenantSupport.full_protected?
    MultiTenantSupport::Current.protection_state = MultiTenantSupport::UNPROTECTED
    assert MultiTenantSupport.full_protected?
  end

  test '.allow_read_across_tenant?' do
    MultiTenantSupport::Current.tenant_account = nil

    MultiTenantSupport::Current.protection_state = MultiTenantSupport::PROTECTED
    refute MultiTenantSupport.allow_read_across_tenant?
    MultiTenantSupport::Current.protection_state = MultiTenantSupport::PROTECTED_EXCEPT_READ
    assert MultiTenantSupport.allow_read_across_tenant?
    MultiTenantSupport::Current.protection_state = MultiTenantSupport::UNPROTECTED
    assert MultiTenantSupport.allow_read_across_tenant?

    MultiTenantSupport::Current.tenant_account = amazon

    MultiTenantSupport::Current.protection_state = MultiTenantSupport::PROTECTED
    refute MultiTenantSupport.allow_read_across_tenant?
    MultiTenantSupport::Current.protection_state = MultiTenantSupport::PROTECTED_EXCEPT_READ
    refute MultiTenantSupport.allow_read_across_tenant?
    MultiTenantSupport::Current.protection_state = MultiTenantSupport::UNPROTECTED
    refute MultiTenantSupport.allow_read_across_tenant?
  end

  test '.unprotected?' do
    MultiTenantSupport::Current.tenant_account = nil

    MultiTenantSupport::Current.protection_state = MultiTenantSupport::PROTECTED
    refute MultiTenantSupport.unprotected?
    MultiTenantSupport::Current.protection_state = MultiTenantSupport::PROTECTED_EXCEPT_READ
    refute MultiTenantSupport.unprotected?
    MultiTenantSupport::Current.protection_state = MultiTenantSupport::UNPROTECTED
    assert MultiTenantSupport.unprotected?

    MultiTenantSupport::Current.tenant_account = amazon

    MultiTenantSupport::Current.protection_state = MultiTenantSupport::PROTECTED
    refute MultiTenantSupport.unprotected?
    MultiTenantSupport::Current.protection_state = MultiTenantSupport::PROTECTED_EXCEPT_READ
    refute MultiTenantSupport.unprotected?
    MultiTenantSupport::Current.protection_state = MultiTenantSupport::UNPROTECTED
    refute MultiTenantSupport.unprotected?
  end

  test ".turn_on_full_protection" do
    MultiTenantSupport::Current.protection_state = MultiTenantSupport::PROTECTED_EXCEPT_READ
    refute MultiTenantSupport.full_protected?
    MultiTenantSupport.turn_on_full_protection
    assert MultiTenantSupport.full_protected?

    MultiTenantSupport::Current.protection_state = MultiTenantSupport::UNPROTECTED
    refute MultiTenantSupport.full_protected?
    MultiTenantSupport.turn_on_full_protection
    assert MultiTenantSupport.full_protected?
  end

  test ".allow_read_across_tenant" do
    MultiTenantSupport::Current.protection_state = MultiTenantSupport::PROTECTED
    refute MultiTenantSupport.allow_read_across_tenant?
    MultiTenantSupport.allow_read_across_tenant
    assert MultiTenantSupport.allow_read_across_tenant?

    MultiTenantSupport::Current.protection_state = MultiTenantSupport::UNPROTECTED
    assert MultiTenantSupport.allow_read_across_tenant?
    MultiTenantSupport.allow_read_across_tenant
    assert MultiTenantSupport.allow_read_across_tenant?

    assert_raise "Cannot read across tenant, try wrap in without_current_tenant" do
      MultiTenantSupport.under_tenant amazon do
        MultiTenantSupport.allow_read_across_tenant do
          # Do something
        end
      end
    end
  end

  test ".turn_off_protection" do
    MultiTenantSupport::Current.protection_state = MultiTenantSupport::PROTECTED
    refute MultiTenantSupport.unprotected?
    MultiTenantSupport.turn_off_protection
    assert MultiTenantSupport.unprotected?

    MultiTenantSupport::Current.protection_state = MultiTenantSupport::PROTECTED_EXCEPT_READ
    refute MultiTenantSupport.unprotected?
    MultiTenantSupport.turn_off_protection
    assert MultiTenantSupport.unprotected?

    assert_raise "Cannot turn off protection, try wrap in without_current_tenant" do
      MultiTenantSupport.under_tenant amazon do
        MultiTenantSupport.turn_off_protection do
          # Do something
        end
      end
    end
  end

  test ".turn_on_full_protection - accept block" do
    MultiTenantSupport::Current.protection_state = MultiTenantSupport::PROTECTED_EXCEPT_READ
    refute MultiTenantSupport.full_protected?

    MultiTenantSupport.turn_on_full_protection do
      assert MultiTenantSupport.full_protected?
    end

    refute MultiTenantSupport.full_protected?
  end

  test ".allow_read_across_tenant - accept block" do
    MultiTenantSupport::Current.protection_state = MultiTenantSupport::PROTECTED
    refute MultiTenantSupport.allow_read_across_tenant?

    MultiTenantSupport.allow_read_across_tenant do
      assert MultiTenantSupport.allow_read_across_tenant?
    end

    refute MultiTenantSupport.allow_read_across_tenant?
  end

  test ".turn_off_protection - accept block" do
    MultiTenantSupport::Current.protection_state = MultiTenantSupport::PROTECTED
    refute MultiTenantSupport.unprotected?

    MultiTenantSupport.turn_off_protection do
      assert MultiTenantSupport.unprotected?
    end

    refute MultiTenantSupport.unprotected?
  end

end
