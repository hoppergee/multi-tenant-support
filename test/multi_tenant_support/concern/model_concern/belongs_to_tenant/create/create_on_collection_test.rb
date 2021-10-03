require 'test_helper'


class ModelCreateOnCollectionProtectTest < ActiveSupport::TestCase

  ####
  #     .create on collection
  ####
  test "can create by tenant" do
    within_a_request_of apple do
      assert_create
    end
  end

  test "cannot create when tenant is missing" do
    disallow_read_across_tenant do
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

  ####
  #     #create!
  ####
  test "can create! by tenant" do
    within_a_request_of apple do
      assert_create!
    end
  end

  test "cannot create! when tenant is missing" do
    disallow_read_across_tenant do
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

  private

  def assert_create
    assert_difference "User.unscope_tenant.count", 1 do
      cook = countries(:us).users.create(name: 'Tim Cook', email: 'cook@example.com')
      assert_equal apple, cook.account 
    end
  end

  def refute_create(error)
    assert_raise(error) do
      countries(:us).users.create(name: 'Tim Cook', email: 'cook@example.com')
    end

    allow_read_across_tenant do
      assert_equal 3, User.unscope_tenant.count
    end
  end

  def assert_create!
    assert_difference "User.unscope_tenant.count", 1 do
      cook = countries(:us).users.create!(name: 'Tim Cook', email: 'cook@example.com')
      assert_equal apple, cook.account 
    end
  end

  def refute_create!(error)
    assert_raise(error) do
      countries(:us).users.create!(name: 'Tim Cook', email: 'cook@example.com')
    end

    allow_read_across_tenant do
      assert_equal 3, User.unscope_tenant.count
    end
  end
end
