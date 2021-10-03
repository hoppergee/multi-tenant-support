require 'test_helper'


class ModelUpdateProtectTest < ActiveSupport::TestCase

  ####
  #     #update
  ####
  test "can update by tenant" do
    within_a_request_of amazon do
      assert_update bezos
    end
  end

  test "cannot update when tenant is missing" do
    disallow_read_across_tenant do
      missing_tenant do
        refute_update bezos, error: MultiTenantSupport::MissingTenantError
      end
    end
  end

  test "cannot update by other tenant" do
    within_a_request_of apple do
      refute_update bezos, error: MultiTenantSupport::InvalidTenantAccess
    end
  end

  test 'cannot update by super admin (default)' do
    within_a_request_of super_admin do
      refute_update bezos, error: MultiTenantSupport::MissingTenantError
    end
  end

  test 'can update by super admin through manual set current tenant' do
    within_a_request_of super_admin do
      under_tenant amazon do
        assert_update bezos
      end
    end
  end

  ####
  #     #update!
  ####
  test "can update! by tenant" do
    within_a_request_of amazon do
      assert_update! bezos
    end
  end

  test "cannot update! when tenant is missing" do
    disallow_read_across_tenant do
      missing_tenant do
        refute_update! bezos, error: MultiTenantSupport::MissingTenantError
      end
    end
  end

  test "cannot update! by other tenant" do
    within_a_request_of apple do
      refute_update! bezos, error: MultiTenantSupport::InvalidTenantAccess
    end
  end

  test 'cannot update! by super admin (default)' do
    within_a_request_of super_admin do
      refute_update! bezos, error: MultiTenantSupport::MissingTenantError
    end
  end

  test 'can update! by super admin through manual set current tenant' do
    within_a_request_of super_admin do
      under_tenant amazon do
        assert_update! bezos
      end
    end
  end

  private

  def assert_update(bezos)
    bezos.name = "JEFF BEZOS"
    assert bezos.update(name: 'JEFF BEZOS')

    under_tenant amazon do
      assert_equal "JEFF BEZOS", bezos.reload.name
    end
  end

  def refute_update(bezos, error:)
    bezos.name = "JEFF BEZOS"

    assert_raise(error) { bezos.update(name: 'JEFF BEZOS') }

    under_tenant amazon do
      assert_equal "Jeff Bezos", bezos.reload.name
    end
  end

  def assert_update!(bezos)
    bezos.name = "JEFF BEZOS"
    assert bezos.update!(name: 'JEFF BEZOS')

    under_tenant amazon do
      assert_equal "JEFF BEZOS", bezos.reload.name
    end
  end

  def refute_update!(bezos, error:)
    bezos.name = "JEFF BEZOS"

    assert_raise(error) { bezos.update!(name: 'JEFF BEZOS') }

    under_tenant amazon do
      assert_equal "Jeff Bezos", bezos.reload.name
    end
  end

end
