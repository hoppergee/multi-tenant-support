require 'test_helper'


class ModelDestroyAllOnBatchProtectTest < ActiveSupport::TestCase

  ####
  # .destroy_all
  ####
  test "can only destroy records under the tenant" do
    within_a_request_of amazon do
      assert_destroy_all(-1)
    end
  end

  test "fail to destroy when tenant is missing" do
    turn_on_full_protection do
      missing_tenant do
        refute_destroy_all MultiTenantSupport::MissingTenantError
      end
    end
  end

  test 'cannot destroy by super admin (default)' do
    within_a_request_of super_admin do
      refute_destroy_all MultiTenantSupport::MissingTenantError
    end
  end

  test 'can destroy scoped records by super admin through manual set current tenant' do
    within_a_request_of super_admin do
      under_tenant amazon do
        assert_destroy_all(-1)
      end
    end
  end

  test 'can destroy scoped records by super admin through manual turn off protection' do
    within_a_request_of super_admin do
      turn_off_protection do
        assert_destroy_all(-3)
      end
    end
  end

  def assert_destroy_all(number_change)
    assert_difference "User.unscope_tenant.count", number_change do
      User.in_batches.destroy_all
    end

    as_super_admin do
      assert_equal (3 + number_change), User.unscope_tenant.count
    end
  end

  def refute_destroy_all(error = nil)
    assert_raise(error) { User.in_batches.destroy_all }

    as_super_admin do
      assert_equal 3, User.count
    end
  end

end
