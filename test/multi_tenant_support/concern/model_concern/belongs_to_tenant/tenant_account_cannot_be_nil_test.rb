require 'test_helper'

class MultiTenantSupport::ModelConcern::BelongsToTenant_TenantAccountCannotBeNil < ActiveSupport::TestCase

  test "raise error when assign nil to account" do
    MultiTenantSupport.under_tenant(accounts(:amazon)) do
      assert_raise(MultiTenantSupport::NilTenantError) { users(:bezos).account = nil }
    end
  end

  test "raise error when assign nil to account_id" do
    MultiTenantSupport.under_tenant(accounts(:amazon)) do
      assert_raise(MultiTenantSupport::NilTenantError) { users(:bezos).account_id = nil }
    end
  end

  test "raise error when change account to nil through .update" do
    MultiTenantSupport.under_tenant(accounts(:amazon)) do
      assert_raise(MultiTenantSupport::NilTenantError) { users(:bezos).update(account: nil) }
    end
  end

  test "raise error when change account_id to nil through .update" do
    MultiTenantSupport.under_tenant(accounts(:amazon)) do
      assert_raise(MultiTenantSupport::NilTenantError) { users(:bezos).update(account_id: nil) }
    end
  end

  test "raise error when change account to nil through .update_attribute" do
    MultiTenantSupport.under_tenant(accounts(:amazon)) do
      assert_raise(MultiTenantSupport::NilTenantError) { users(:bezos).update_attribute(:account, nil) }
    end
  end

  test "raise error when change account_id to nil through .update_attribute" do
    MultiTenantSupport.under_tenant(accounts(:amazon)) do
      assert_raise("account_id is marked as readonly") { users(:bezos).update_attribute(:account_id, nil) }
    end
  end

  test "raise error when change account_id to nil through .update_columns" do
    MultiTenantSupport.under_tenant(accounts(:amazon)) do
      assert_raise("account_id is marked as readonly") { users(:bezos).update_columns(account_id: nil) }
    end
  end

  test "raise error when change account_id to nil through .update_column" do
    MultiTenantSupport.under_tenant(accounts(:amazon)) do
      assert_raise("account_id is marked as readonly") { users(:bezos).update_column(:account_id, nil) }
    end
  end

end
