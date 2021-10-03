require 'test_helper'


class ModelInsertProtectTest < ActiveSupport::TestCase

  ####
  #     .insert
  ####
  test "can insert by tenant" do
    within_a_request_of apple do
      assert_insert
    end
  end

  test "cannot insert when tenant is missing" do
    disallow_read_across_tenant do
      missing_tenant do
        refute_insert MultiTenantSupport::MissingTenantError
      end
    end
  end

  test 'cannot insert by super admin (default)' do
    within_a_request_of super_admin do
      refute_insert MultiTenantSupport::MissingTenantError
    end
  end

  test 'can insert by super admin through manual set current tenant' do
    within_a_request_of super_admin do
      under_tenant apple do
        assert_insert
      end
    end
  end

  ####
  #     #insert!
  ####
  test "can insert! by tenant" do
    within_a_request_of apple do
      assert_insert!
    end
  end

  test "cannot insert! when tenant is missing" do
    disallow_read_across_tenant do
      missing_tenant do
        refute_insert! MultiTenantSupport::MissingTenantError
      end
    end
  end

  test 'cannot insert! by super admin (default)' do
    within_a_request_of super_admin do
      refute_insert! MultiTenantSupport::MissingTenantError
    end
  end

  test 'can insert! by super admin through manual set current tenant' do
    within_a_request_of super_admin do
      under_tenant apple do
        assert_insert!
      end
    end
  end

  private

  def assert_insert
    assert_difference "User.unscope_tenant.count", 1 do
      User.insert({name: 'Tim Cook', email: 'cook@example.com', created_at: Time.current, updated_at: Time.current})
      assert_equal apple, User.find_by(name: 'Tim Cook').account 
    end
  end

  def refute_insert(error)
    assert_raise(error) { User.insert({email: 'test@test.com'}) }

    allow_read_across_tenant do
      assert_equal 3, User.unscope_tenant.count
    end
  end

  def assert_insert!
    assert_difference "User.unscope_tenant.count", 1 do
      User.insert!({name: 'Tim Cook', email: 'cook@example.com', created_at: Time.current, updated_at: Time.current})
      assert_equal apple, User.find_by(name: 'Tim Cook').account 
    end
  end

  def refute_insert!(error)
    assert_raise(error) { User.insert!({email: 'test@test.com'}) }

    allow_read_across_tenant do
      assert_equal 3, User.unscope_tenant.count
    end
  end
end
