require 'test_helper'

class MultiTenantSupport::ModelConcern::BelongsToTenant_ReadonlyTenantAccountTest < ActiveSupport::TestCase

  test "raise error when assign user.account" do
    MultiTenantSupport.under_tenant accounts(:amazon) do
      assert_raise(MultiTenantSupport::ImmutableTenantError) { users(:bezos).account = accounts(:facebook) }
    end
  end

  test "raise error when assign user.account_id" do
    MultiTenantSupport.under_tenant accounts(:amazon) do
      assert_raise(MultiTenantSupport::ImmutableTenantError) { users(:bezos).account_id = accounts(:facebook).id }
    end
  end

  test "raise error when change account through .update" do
    MultiTenantSupport.under_tenant accounts(:amazon) do
      assert_raise(MultiTenantSupport::ImmutableTenantError) { users(:bezos).update(account: accounts(:facebook)) }
    end
  end

  test "raise error when change account_id through .update" do
    MultiTenantSupport.under_tenant accounts(:amazon) do
      assert_raise(MultiTenantSupport::ImmutableTenantError) { users(:bezos).update(account_id: accounts(:facebook).id) }
    end
  end

  test "raise error when change account through .update_attribute" do
    MultiTenantSupport.under_tenant accounts(:amazon) do
      assert_raise(MultiTenantSupport::ImmutableTenantError) { users(:bezos).update_attribute(:account, accounts(:facebook)) }
    end
  end

  test "raise error when change account_id through .update_attribute" do
    MultiTenantSupport.under_tenant accounts(:amazon) do
      assert_raise("account_id is marked as readonly") { users(:bezos).update_attribute(:account_id, accounts(:facebook).id) }
    end
  end

  test "raise error when change account_id through .update_columns" do
    MultiTenantSupport.under_tenant accounts(:amazon) do
      assert_raise("account_id is marked as readonly") { users(:bezos).update_columns(account_id: accounts(:facebook).id) }
    end
  end

  test "raise error when change account_id through .update_column" do
    MultiTenantSupport.under_tenant accounts(:amazon) do
      assert_raise("account_id is marked as readonly") { users(:bezos).update_column(:account_id, accounts(:facebook).id) }
    end
  end

end
