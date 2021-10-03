require 'test_helper'


class ModelDeleteAllProtectTest < ActiveSupport::TestCase

  ####
  # .delete_all
  ####
  test "can only delete records under the tenant" do
    within_a_request_of amazon do
      assert_delete_all(-1)
    end
  end

  test "fail to delete when tenant is missing" do
    disallow_read_across_tenant do
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

  def assert_delete_all(number_change)
    assert_difference "User.unscope_tenant.count", number_change do
      User.delete_all
    end
  end

  def refute_delete_all(error = nil)
    assert_raise(error) { User.delete_all }

    allow_read_across_tenant do
      assert_equal 3, User.count
    end
  end

end
