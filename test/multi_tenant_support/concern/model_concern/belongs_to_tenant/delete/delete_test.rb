require 'test_helper'


class ModelDeleteProtectTest < ActiveSupport::TestCase

  ####
  #     #delete
  ####
  test "can delete by tenant" do
    within_a_request_of amazon do
      assert_delete bezos
    end
  end

  test "cannot delete when tenant is missing" do
    turn_on_full_protection do
      missing_tenant do
        refute_delete bezos, error: MultiTenantSupport::MissingTenantError
      end
    end
  end

  test "cannot delete by other tenant" do
    within_a_request_of apple do
      refute_delete bezos, error: MultiTenantSupport::InvalidTenantAccess
    end
  end

  test 'cannot delete by super admin default' do
    within_a_request_of super_admin do
      refute_delete bezos, error: MultiTenantSupport::MissingTenantError
    end
  end

  test 'can delete by super admin through manual set current tenant' do
    within_a_request_of super_admin do
      under_tenant amazon do
        assert_delete bezos
      end
    end
  end

  test 'can delete by super admin through manual turn off protection' do
    within_a_request_of super_admin do
      turn_off_protection do
        assert_delete bezos
      end
    end
  end

  private

  def assert_delete(user)
    assert_difference "User.unscope_tenant.count", -1 do
      user.delete
    end
  end

  def refute_delete(user, error:)
    assert_raise(error) { user.delete }

    under_tenant user.account do
      assert user.reload.persisted?
    end
  end

end
