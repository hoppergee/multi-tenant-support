require 'test_helper'


class ModelUpdateAllProtectTest < ActiveSupport::TestCase

  ####
  #     #update_all
  ####
  test "can update_all by tenant" do
    within_a_request_of amazon do
      assert_update_all affect: 1
    end
  end

  test "cannot update_all when tenant is missing" do
    turn_on_full_protection do
      missing_tenant do
        refute_update_all MultiTenantSupport::MissingTenantError
      end
    end
  end

  test 'cannot update_all by super admin (default)' do
    within_a_request_of super_admin do
      refute_update_all MultiTenantSupport::MissingTenantError
    end
  end

  test 'can update_all by super admin through manual set current tenant' do
    within_a_request_of super_admin do
      under_tenant amazon do
        assert_update_all affect: 1
      end
    end
  end

  test 'can update_all by super admin through manual turn off protection' do
    within_a_request_of super_admin do
      turn_off_protection do
        assert_update_all affect: 3
      end
    end
  end

  private

  def assert_update_all(affect:)
    User.update_all(name: 'NAME')

    as_super_admin do
      without_current_tenant do
        assert_equal 3, User.count
        assert_equal affect, User.where(name: 'NAME').count
      end
    end
  end

  def refute_update_all(error)
    assert_raise(error) { User.update_all(name: 'NAME') }

    as_super_admin do
      without_current_tenant do
        refute User.pluck(:name).include?('NAME')
      end
    end
  end

end
