require 'test_helper'


class ModelUpdateBySaveProtectTest < ActiveSupport::TestCase

  ####
  #     #save
  ####
  test "can save by tenant" do
    within_a_request_of amazon do
      assert_save bezos
    end
  end

  test "cannot save when tenant is missing" do
    turn_on_full_protection do
      missing_tenant do
        refute_save bezos, error: MultiTenantSupport::MissingTenantError
      end
    end
  end

  test "cannot save by other tenant" do
    within_a_request_of apple do
      refute_save bezos, error: MultiTenantSupport::InvalidTenantAccess
    end
  end

  test 'cannot save by super admin (default)' do
    within_a_request_of super_admin do
      refute_save bezos, error: MultiTenantSupport::MissingTenantError
    end
  end

  test 'can save by super admin through manual set current tenant' do
    within_a_request_of super_admin do
      under_tenant amazon do
        assert_save bezos
      end
    end
  end

  test 'can save by super admin through manual turn off protection' do
    within_a_request_of super_admin do
      turn_off_protection do
        assert_save bezos
      end
    end
  end

  ####
  #     #save!
  ####
  test "can save! by tenant" do
    within_a_request_of amazon do
      assert_save! bezos
    end
  end

  test "cannot save! when tenant is missing" do
    turn_on_full_protection do
      missing_tenant do
        refute_save! bezos, error: MultiTenantSupport::MissingTenantError
      end
    end
  end

  test "cannot save! by other tenant" do
    within_a_request_of apple do
      refute_save! bezos, error: MultiTenantSupport::InvalidTenantAccess
    end
  end

  test 'cannot save! by super admin (default)' do
    within_a_request_of super_admin do
      refute_save! bezos, error: MultiTenantSupport::MissingTenantError
    end
  end

  test 'can save! by super admin through manual set current tenant' do
    within_a_request_of super_admin do
      under_tenant amazon do
        assert_save! bezos
      end
    end
  end

  private

  def assert_save(bezos)
    bezos.name = "JEFF BEZOS"
    assert bezos.save
    assert_equal "JEFF BEZOS", bezos.name
  end

  def refute_save(bezos, error:)
    bezos.name = "JEFF BEZOS"

    assert_raise(error) { bezos.save }

    under_tenant amazon do
      assert_equal "Jeff Bezos", bezos.reload.name
    end
  end

  def assert_save!(user)
    user.name = "JEFF BEZOS"
    assert user.save!
    assert_equal "JEFF BEZOS", user.name
  end

  def refute_save!(user, error:)
    bezos.name = "JEFF BEZOS"

    assert_raise(error) { bezos.save! }

    under_tenant amazon do
      assert_equal "Jeff Bezos", bezos.reload.name
    end
  end
end
