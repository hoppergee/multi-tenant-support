require 'test_helper'


class ModelCreateBySaveProtectTest < ActiveSupport::TestCase

  setup do
    under_tenant apple do
      @cook = User.new(name: 'Tim Cook', email: 'cook@example.com')
    end
  end

  ####
  #     create by #save
  ####
  test "can save by tenant" do
    within_a_request_of apple do
      assert_save @cook
    end
  end

  test "cannot save when tenant is missing" do
    turn_on_full_protection do
      missing_tenant do
        refute_save @cook, error: MultiTenantSupport::MissingTenantError
      end
    end
  end

  test 'cannot save by super admin (default)' do
    within_a_request_of super_admin do
      refute_save @cook, error: MultiTenantSupport::MissingTenantError
    end
  end

  test 'can save by super admin through manual set current tenant' do
    within_a_request_of super_admin do
      under_tenant apple do
        assert_save @cook
      end
    end
  end

  test 'can save by super admin through manual turn off protection' do
    within_a_request_of super_admin do
      turn_off_protection do
        assert_save @cook
      end
    end
  end

  ####
  #     #save!
  ####
  test "can save! by tenant" do
    within_a_request_of apple do
      assert_save! @cook
    end
  end

  test "cannot save! when tenant is missing" do
    turn_on_full_protection do
      missing_tenant do
        refute_save! @cook, error: MultiTenantSupport::MissingTenantError
      end
    end
  end

  test 'cannot save! by super admin (default)' do
    within_a_request_of super_admin do
      refute_save! @cook, error: MultiTenantSupport::MissingTenantError
    end
  end

  test 'can save! by super admin through manual set current tenant' do
    within_a_request_of super_admin do
      under_tenant apple do
        assert_save! @cook
      end
    end
  end

  test 'can save! by super admin through manual turn off protection' do
    within_a_request_of super_admin do
      turn_off_protection do
        assert_save! @cook
      end
    end
  end

  private

  def assert_save(user)
    assert_difference "User.unscope_tenant.count", 1 do
      assert user.save
      assert apple, user.account
    end
  end

  def refute_save(user, error:)
    assert_raise(error) { user.save }

    as_super_admin do
      assert_equal 3, User.unscope_tenant.count
    end
  end

  def assert_save!(user)
    assert_difference "User.unscope_tenant.count", 1 do
      assert user.save!
      assert apple, user.account
    end
  end

  def refute_save!(user, error:)
    assert_raise(error) { user.save! }

    as_super_admin do
      assert_equal 3, User.unscope_tenant.count
    end
  end
end
