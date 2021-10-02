require 'test_helper'


class ModelDestroyByProtectTest < ActiveSupport::TestCase

  ####
  # .destroy_by
  ####
  test "can destroy by tenant" do
    within_a_request_of amazon do
      assert_destroy_by name: 'Jeff Bezos'
    end
  end

  test "cannot destroy when tenant is missing" do
    disallow_read_across_tenant do
      missing_tenant do
        refute_destroy_by name: 'Jeff Bezos', error: MultiTenantSupport::MissingTenantError
      end
    end
  end

  test "cannot destroy by other tenant" do
    within_a_request_of facebook do
      refute_destroy_by name: 'Jeff Bezos'
    end
  end

  test 'cannot destroy by super admin (default)' do
    within_a_request_of super_admin do
      refute_destroy_by name: 'Jeff Bezos', error: MultiTenantSupport::MissingTenantError
    end
  end

  test 'can destroy by super admin through manual set current tenant' do
    within_a_request_of super_admin do
      under_tenant amazon do
        assert_destroy_by name: 'Jeff Bezos'
      end
    end
  end

  def assert_destroy_by(condition)
    assert_difference "User.unscope_tenant.count", -1 do
      User.destroy_by(condition)
    end
  end

  def refute_destroy_by(name:, error: nil)
    if error
      assert_raise(error) { User.destroy_by(name: name) }
    else
      assert_no_difference "User.unscope_tenant.count" do
        User.destroy_by(name: name)
      end
    end

    allow_read_across_tenant do
      assert_equal 3, User.unscope_tenant.count
    end
  end

end
