require 'test_helper'


class ModelUpdateAttributeProtectTest < ActiveSupport::TestCase

  ####
  #     #update_attribute
  ####
  test "can update_attribute by tenant" do
    within_a_request_of amazon do
      assert_update_attribute bezos
    end
  end

  test "cannot update_attribute when tenant is missing" do
    disallow_read_across_tenant do
      missing_tenant do
        refute_update_attribute bezos, error: MultiTenantSupport::MissingTenantError
      end
    end
  end

  test "cannot update_attribute by other tenant" do
    within_a_request_of apple do
      refute_update_attribute bezos, error: MultiTenantSupport::InvalidTenantAccess
    end
  end

  test 'cannot update_attribute by super admin (default)' do
    within_a_request_of super_admin do
      refute_update_attribute bezos, error: MultiTenantSupport::MissingTenantError
    end
  end

  test 'can update_attribute by super admin through manual set current tenant' do
    within_a_request_of super_admin do
      under_tenant amazon do
        assert_update_attribute bezos
      end
    end
  end

  private

  def assert_update_attribute(bezos)
    assert bezos.update_attribute(:name, 'JEFF BEZOS')

    under_tenant amazon do
      assert_equal "JEFF BEZOS", bezos.reload.name
    end
  end

  def refute_update_attribute(bezos, error:)
    assert_raise(error) { bezos.update_attribute(:name, 'JEFF BEZOS') }

    under_tenant amazon do
      assert_equal "Jeff Bezos", bezos.reload.name
    end
  end

end
