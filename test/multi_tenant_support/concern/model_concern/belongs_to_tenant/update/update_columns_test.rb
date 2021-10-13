require 'test_helper'


class ModelUpdateColumnsProtectTest < ActiveSupport::TestCase

  ####
  #     #update_columns
  ####
  test "can update_columns by tenant" do
    within_a_request_of amazon do
      assert_update_columns bezos
    end
  end

  test "cannot update_columns when tenant is missing" do
    turn_on_full_protection do
      missing_tenant do
        refute_update_columns bezos, error: MultiTenantSupport::MissingTenantError
      end
    end
  end

  test "cannot update_columns by other tenant" do
    within_a_request_of apple do
      refute_update_columns bezos, error: MultiTenantSupport::InvalidTenantAccess
    end
  end

  test 'cannot update_columns by super admin (default)' do
    within_a_request_of super_admin do
      refute_update_columns bezos, error: MultiTenantSupport::MissingTenantError
    end
  end

  test 'can update_columns by super admin through manual set current tenant' do
    within_a_request_of super_admin do
      under_tenant amazon do
        assert_update_columns bezos
      end
    end
  end

  test 'can update_columns by super admin through manual turn off protection' do
    within_a_request_of super_admin do
      turn_off_protection do
        assert_update_columns bezos
      end
    end
  end

  private

  def assert_update_columns(bezos)
    assert bezos.update_columns(name: 'JEFF BEZOS')

    under_tenant amazon do
      assert_equal "JEFF BEZOS", bezos.reload.name
    end
  end

  def refute_update_columns(bezos, error:)
    assert_raise(error) { bezos.update_columns(name: 'JEFF BEZOS') }

    under_tenant amazon do
      assert_equal "Jeff Bezos", bezos.reload.name
    end
  end

end
