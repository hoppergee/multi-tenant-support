require 'test_helper'


class ModelDeleteAllOnCollectionProtectTest < ActiveSupport::TestCase

  ####
  # .delete_all
  ####
  test "can only delete records under the tenant" do
    within_a_request_of amazon do
      assert_delete_all(-1)
    end
  end

  test "fail to delete when tenant is missing" do
    turn_on_full_protection do
      missing_tenant do
        refute_delete_all MultiTenantSupport::MissingTenantError
      end
    end
  end

  test 'cannot delete by super admin (default)' do
    within_a_request_of super_admin do
      refute_delete_all MultiTenantSupport::MissingTenantError
    end
  end

  test 'can delete scoped records by super admin through manual set current tenant' do
    within_a_request_of super_admin do
      under_tenant amazon do
        assert_delete_all(-1)
      end
    end
  end

  test 'can delete all records by super admin through manual turn off protection' do
    within_a_request_of super_admin do
      turn_off_protection do
        assert_delete_all(-3)
      end
    end
  end

  def assert_delete_all(number_change)
    assert_difference "UserTag.unscope_tenant.count", number_change do
      tags(:entrepreneur).users.delete_all
    end

    as_super_admin do
      assert_equal (3 + number_change), UserTag.unscope_tenant.count
      assert_equal 3, User.unscope_tenant.count
    end
  end

  def refute_delete_all(error = nil)
    assert_raise(error) { tags(:entrepreneur).users.delete_all }

    as_super_admin do
      assert_equal 3, User.count
      assert_equal 3, UserTag.count
    end
  end

end
