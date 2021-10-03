require 'test_helper'

class ModelDestroyOnClassProtectTest < ActiveSupport::TestCase

  ####
  #     .destroy
  ####
  test "can destroy by tenant" do
    within_a_request_of amazon do
      assert_destroy bezos
    end
  end

  test "cannot destroy when tenant is missing" do
    disallow_read_across_tenant do
      missing_tenant do
        refute_destroy bezos, error: MultiTenantSupport::MissingTenantError
      end
    end
  end

  test "cannot destroy by other tenant" do
    within_a_request_of apple do
      refute_destroy bezos, error: ActiveRecord::RecordNotFound
    end
  end

  test 'cannot destroy by super admin default' do
    within_a_request_of super_admin do
      refute_destroy bezos, error: MultiTenantSupport::MissingTenantError
    end
  end

  test 'can destroy by super admin through manual set current tenant' do
    within_a_request_of super_admin do
      under_tenant amazon do
        assert_destroy bezos
      end
    end
  end

  private

  def assert_destroy(user)
    assert_difference "User.count", -1 do
      User.destroy(user.id)
    end
  end

  def refute_destroy(user, error:)
    assert_raise(error) { User.destroy(user.id) }

    under_tenant user.account do
      assert user.reload.persisted?
    end
  end

end
