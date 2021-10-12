require 'test_helper'


class ModelCreateProtectTest < ActiveSupport::TestCase

  ####
  #     .create
  ####
  test "can create by tenant" do
    within_a_request_of apple do
      assert_create
    end
  end

  test "cannot create when tenant is missing" do
    turn_on_full_protection do
      missing_tenant do
        refute_create MultiTenantSupport::MissingTenantError
      end
    end
  end

  test 'cannot create by super admin (default)' do
    within_a_request_of super_admin do
      refute_create MultiTenantSupport::MissingTenantError
    end
  end

  test 'can create by super admin through manual set current tenant' do
    within_a_request_of super_admin do
      under_tenant apple do
        assert_create
      end
    end
  end

  test 'cannot create without account by super admin through manual turn off protection' do
    within_a_request_of super_admin do
      turn_off_protection do
        assert_no_difference "User.unscope_tenant.count" do
          cook = User.create(name: 'Tim Cook', email: 'cook@example.com')
          assert_equal ["Account must exist"], cook.errors.full_messages
        end
      end
    end
  end

  ####
  #     #create!
  ####
  test "can create! by tenant" do
    within_a_request_of apple do
      assert_create!
    end
  end

  test "cannot create! when tenant is missing" do
    turn_on_full_protection do
      missing_tenant do
        refute_create! MultiTenantSupport::MissingTenantError
      end
    end
  end

  test 'cannot create! by super admin (default)' do
    within_a_request_of super_admin do
      refute_create! MultiTenantSupport::MissingTenantError
    end
  end

  test 'can create! by super admin through manual set current tenant' do
    within_a_request_of super_admin do
      under_tenant apple do
        assert_create!
      end
    end
  end

  test 'cannot create! without account by super admin through manual turn off protection' do
    within_a_request_of super_admin do
      turn_off_protection do
        assert_no_difference "User.unscope_tenant.count" do
          assert_raise "Account must exist" do
            User.create!(name: 'Tim Cook', email: 'cook@example.com')
          end
        end
      end
    end
  end

  private

  def assert_create
    assert_difference "User.unscope_tenant.count", 1 do
      cook = User.create(name: 'Tim Cook', email: 'cook@example.com')
      assert_equal apple, cook.account 
    end
  end

  def refute_create(error)
    assert_raise(error) do
      User.create(name: 'Tim Cook', email: 'cook@example.com')
    end

    as_super_admin do
      assert_equal 3, User.unscope_tenant.count
    end
  end

  def assert_create!
    assert_difference "User.unscope_tenant.count", 1 do
      cook = User.create!(name: 'Tim Cook', email: 'cook@example.com')
      assert_equal apple, cook.account 
    end
  end

  def refute_create!(error)
    assert_raise(error) do
      User.create!(name: 'Tim Cook', email: 'cook@example.com')
    end

    as_super_admin do
      assert_equal 3, User.unscope_tenant.count
    end
  end
end
