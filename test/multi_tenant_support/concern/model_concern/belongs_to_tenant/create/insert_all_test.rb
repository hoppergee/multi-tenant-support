require 'test_helper'


class ModelInsertAllProtectTest < ActiveSupport::TestCase

  ####
  #     .insert_all
  ####
  test "can insert_all by tenant" do
    within_a_request_of apple do
      assert_insert_all
    end
  end

  test "cannot insert_all when tenant is missing" do
    turn_on_full_protection do
      missing_tenant do
        refute_insert_all MultiTenantSupport::MissingTenantError
      end
    end
  end

  test 'cannot insert_all by super admin (default)' do
    within_a_request_of super_admin do
      refute_insert_all MultiTenantSupport::MissingTenantError
    end
  end

  test 'can insert_all by super admin through manual set current tenant' do
    within_a_request_of super_admin do
      under_tenant apple do
        assert_insert_all
      end
    end
  end

  test 'can insert_all without tenant by super admin through manual turn off protection' do
    within_a_request_of super_admin do
      turn_off_protection do
        assert_difference "User.unscope_tenant.count", 2 do
          User.insert_all([
            { id: 99, name: 'Tim Cook', email: 'cook@example.com', created_at: Time.current, updated_at: Time.current },
            { id: 100, name: 'Steve Wozniak', email: 'wozniak@example.com', created_at: Time.current, updated_at: Time.current }
          ])
          assert User.find_by(name: 'Tim Cook').account.nil?
          assert User.find_by(name: 'Steve Wozniak').account.nil?
        end
      end
    end
  end

  ####
  #     #insert_all!
  ####
  test "can insert_all! by tenant" do
    within_a_request_of apple do
      assert_insert_all!
    end
  end

  test "cannot insert_all! when tenant is missing" do
    turn_on_full_protection do
      missing_tenant do
        refute_insert_all! MultiTenantSupport::MissingTenantError
      end
    end
  end

  test 'cannot insert_all! by super admin (default)' do
    within_a_request_of super_admin do
      refute_insert_all! MultiTenantSupport::MissingTenantError
    end
  end

  test 'can insert_all! by super admin through manual set current tenant' do
    within_a_request_of super_admin do
      under_tenant apple do
        assert_insert_all!
      end
    end
  end

  test 'can insert_all! without tenant by super admin through manual turn off protection' do
    within_a_request_of super_admin do
      turn_off_protection do
        assert_difference "User.unscope_tenant.count", 2 do
          User.insert_all!([
            { id: 99, name: 'Tim Cook', email: 'cook@example.com', created_at: Time.current, updated_at: Time.current },
            { id: 100, name: 'Steve Wozniak', email: 'wozniak@example.com', created_at: Time.current, updated_at: Time.current }
          ])
          assert User.find_by(name: 'Tim Cook').account.nil?
          assert User.find_by(name: 'Steve Wozniak').account.nil?
        end
      end
    end
  end

  private

  def assert_insert_all
    assert_difference "User.unscope_tenant.count", 2 do
      User.insert_all([
        { id: 99, name: 'Tim Cook', email: 'cook@example.com', created_at: Time.current, updated_at: Time.current },
        { id: 100, name: 'Steve Wozniak', email: 'wozniak@example.com', created_at: Time.current, updated_at: Time.current }
      ])
      assert_equal apple, User.find_by(name: 'Tim Cook').account 
      assert_equal apple, User.find_by(name: 'Steve Wozniak').account 
    end
  end

  def refute_insert_all(error)
    assert_raise(error) do
      User.insert_all([
        { id: 99, name: 'Tim Cook', email: 'cook@example.com', created_at: Time.current, updated_at: Time.current },
        { id: 100, name: 'Steve Wozniak', email: 'wozniak@example.com', created_at: Time.current, updated_at: Time.current }
      ])
    end

    as_super_admin do
      assert_equal 3, User.unscope_tenant.count
    end
  end

  def assert_insert_all!
    assert_difference "User.unscope_tenant.count", 2 do
      User.insert_all!([
        { id: 99, name: 'Tim Cook', email: 'cook@example.com', created_at: Time.current, updated_at: Time.current },
        { id: 100, name: 'Steve Wozniak', email: 'wozniak@example.com', created_at: Time.current, updated_at: Time.current }
      ])
      assert_equal apple, User.find_by(name: 'Tim Cook').account 
      assert_equal apple, User.find_by(name: 'Steve Wozniak').account 
    end
  end

  def refute_insert_all!(error)
    assert_raise(error) do
      User.insert_all!([
        { id: 99, name: 'Tim Cook', email: 'cook@example.com', created_at: Time.current, updated_at: Time.current },
        { id: 100, name: 'Steve Wozniak', email: 'wozniak@example.com', created_at: Time.current, updated_at: Time.current }
      ])
    end

    as_super_admin do
      assert_equal 3, User.unscope_tenant.count
    end
  end
end
