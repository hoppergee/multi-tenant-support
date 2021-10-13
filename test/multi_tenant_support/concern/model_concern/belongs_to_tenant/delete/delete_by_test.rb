require 'test_helper'


class ModelDeleteByProtectTest < ActiveSupport::TestCase

  ####
  # .delete_by
  ####
  test "can delete by tenant" do
    within_a_request_of amazon do
      assert_delete_by name: 'Jeff Bezos'
    end
  end

  test "cannot delete when tenant is missing" do
    turn_on_full_protection do
      missing_tenant do
        refute_delete_by name: 'Jeff Bezos', error: MultiTenantSupport::MissingTenantError
      end
    end
  end

  test "cannot delete by other tenant" do
    within_a_request_of facebook do
      refute_delete_by name: 'Jeff Bezos'
    end
  end

  test 'cannot delete by super admin (default)' do
    within_a_request_of super_admin do
      refute_delete_by name: 'Jeff Bezos', error: MultiTenantSupport::MissingTenantError
    end
  end

  test 'can delete by super admin through manual set current tenant' do
    within_a_request_of super_admin do
      under_tenant amazon do
        assert_delete_by name: 'Jeff Bezos'
      end
    end
  end

  test 'can delete by super admin through manual turn off protection' do
    within_a_request_of super_admin do
      turn_off_protection do
        assert_delete_by name: 'Jeff Bezos'
      end
    end
  end

  def assert_delete_by(condition)
    assert_difference "User.unscope_tenant.count", -1 do
      User.delete_by(condition)
    end
  end

  def refute_delete_by(name:, error: nil)
    if error
      assert_raise(error) { User.delete_by(name: name) }
    else
      assert_no_difference "User.unscope_tenant.count" do
        User.delete_by(name: name)
      end
    end

    as_super_admin do
      assert_equal 3, User.unscope_tenant.count
    end
  end

end
