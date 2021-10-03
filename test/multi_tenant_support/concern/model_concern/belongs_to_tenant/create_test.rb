require 'test_helper'

class MultiTenantSupport::ModelConcern::BelongsToTenant_CreateTest < ActiveSupport::TestCase

  ####
  # .insert and insert!
  ####
  test "insert - auto set tenant account on creation" do
    MultiTenantSupport.under_tenant accounts(:amazon) do
      assert_difference 'User.count', 1 do
        User.insert({name: 'tom', email: 'tom@example.com', created_at: Time.current, updated_at: Time.current})
        assert_equal accounts(:amazon), User.find_by(name: 'tom').account
      end

      assert_difference 'User.count', 1 do
        User.insert!({name: 'robin', email: 'robin@example.com', created_at: Time.current, updated_at: Time.current})
        assert_equal accounts(:amazon), User.find_by(name: 'robin').account
      end
    end
  end

  test "insert - raise error on missing tenant when not allow read across tenant (default)" do
    assert_raise(MultiTenantSupport::MissingTenantError) { User.insert({email: 'test@test.com'}) }
    assert_raise(MultiTenantSupport::MissingTenantError) { User.insert!({email: 'test@test.com'}) }
  end

  test "insert - raise error on missing tenant when allow read across tenant" do
    MultiTenantSupport.allow_read_across_tenant do
      assert_raise(MultiTenantSupport::MissingTenantError) { User.insert({email: 'test@test.com'}) }
      assert_raise(MultiTenantSupport::MissingTenantError) { User.insert!({email: 'test@test.com'}) }
    end
  end

  ####
  # .insert_all
  ####
  test ".insert_all - can success insert with default scope" do
    MultiTenantSupport.under_tenant(accounts(:amazon)) do
      User.insert_all([
        { id: 99, name: 'jack', email: 'jack@example.com', created_at: Time.current, updated_at: Time.current },
        { id: 100, name: 'kate', email: 'kate@example.com', created_at: Time.current, updated_at: Time.current }
      ])

      assert accounts(:amazon), User.find(99)
      assert accounts(:amazon), User.find(100)
    end
  end

  test ".insert_all - can't insert when tenant is missing" do
    assert_raise(MultiTenantSupport::MissingTenantError) do
      User.insert_all([
        { id: 99, name: 'jack', email: 'jack@example.com', created_at: Time.current, updated_at: Time.current },
        { id: 100, name: 'kate', email: 'kate@example.com', created_at: Time.current, updated_at: Time.current }
      ])
    end
  end

  test ".insert_all - can't insert when tenant is missing even allow read across tenant" do
    MultiTenantSupport.allow_read_across_tenant do
      assert_raise(MultiTenantSupport::MissingTenantError) do
        User.insert_all([
          { id: 99, name: 'jack', email: 'jack@example.com', created_at: Time.current, updated_at: Time.current },
          { id: 100, name: 'kate', email: 'kate@example.com', created_at: Time.current, updated_at: Time.current }
        ])
      end
    end
  end

  ####
  # .insert_all!
  ####
  test ".insert_all! - can success insert with default scope" do
    MultiTenantSupport.under_tenant(accounts(:amazon)) do
      User.insert_all!([
        { id: 99, name: 'jack', email: 'jack@example.com', created_at: Time.current, updated_at: Time.current },
        { id: 100, name: 'kate', email: 'kate@example.com', created_at: Time.current, updated_at: Time.current }
      ])

      assert accounts(:amazon), User.find(99)
      assert accounts(:amazon), User.find(100)
    end
  end

  test ".insert_all! - can't insert when tenant is missing" do
    assert_raise(MultiTenantSupport::MissingTenantError) do
      User.insert_all!([
        { id: 99, name: 'jack', email: 'jack@example.com', created_at: Time.current, updated_at: Time.current },
        { id: 100, name: 'kate', email: 'kate@example.com', created_at: Time.current, updated_at: Time.current }
      ])
    end
  end

  test ".insert_all! - can't insert when tenant is missing even allow read across tenant" do
    MultiTenantSupport.allow_read_across_tenant do
      assert_raise(MultiTenantSupport::MissingTenantError) do
        User.insert_all!([
          { id: 99, name: 'jack', email: 'jack@example.com', created_at: Time.current, updated_at: Time.current },
          { id: 100, name: 'kate', email: 'kate@example.com', created_at: Time.current, updated_at: Time.current }
        ])
      end
    end
  end

end
