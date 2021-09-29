require 'test_helper'

class MultiTenantSupport::ModelConcern::BelongsToTenant_CreateTest < ActiveSupport::TestCase

  ####
  # .create and .create!
  ####
  test "create - auto set tenant account on creation" do
    MultiTenantSupport.under_tenant accounts(:amazon) do
      kate = User.new(name: 'kate')
      assert kate.save
      assert_equal accounts(:amazon), kate.account

      john = User.create(name: 'john')
      assert_equal accounts(:amazon), john.account

      jack = User.create!(name: 'jack')
      assert_equal accounts(:amazon), jack.account
    end
  end

  test "create - raise error on missing tenant when not allow read across tenant (default)" do
    assert_raise(MultiTenantSupport::MissingTenantError) { User.create(email: 'test@test.com') }
    assert_raise(MultiTenantSupport::MissingTenantError) { User.create!(email: 'test@test.com') }
    assert_raise(MultiTenantSupport::MissingTenantError) do
      u = User.new(email: 'test@test.com')
      u.save
    end
  end

  test "create - raise error on missing tenant when allow read across tenant" do
    MultiTenantSupport.allow_read_across_tenant do
      assert_raise(MultiTenantSupport::MissingTenantError) { User.create(email: 'test@test.com') }
      assert_raise(MultiTenantSupport::MissingTenantError) { User.create!(email: 'test@test.com') }
      assert_raise(MultiTenantSupport::MissingTenantError) do
        u = User.new(email: 'test@test.com')
        u.save
      end
    end
  end

  ####
  # .insert_all
  ####
  test ".insert_all - can success insert with default scope" do
    MultiTenantSupport.under_tenant(accounts(:amazon)) do
      User.insert_all([
        { id: 99, name: 'jack', created_at: Time.current, updated_at: Time.current },
        { id: 100, name: 'kate', created_at: Time.current, updated_at: Time.current }
      ])

      assert accounts(:amazon), User.find(99)
      assert accounts(:amazon), User.find(100)
    end
  end

  test ".insert_all - can't insert when tenant is missing" do
    assert_raise(MultiTenantSupport::MissingTenantError) do
      User.insert_all([
        { id: 99, name: 'jack', created_at: Time.current, updated_at: Time.current },
        { id: 100, name: 'kate', created_at: Time.current, updated_at: Time.current }
      ])
    end
  end

  test ".insert_all - can't insert when tenant is missing even allow read across tenant" do
    MultiTenantSupport.allow_read_across_tenant do
      assert_raise(MultiTenantSupport::MissingTenantError) do
        User.insert_all([
          { id: 99, name: 'jack', created_at: Time.current, updated_at: Time.current },
          { id: 100, name: 'kate', created_at: Time.current, updated_at: Time.current }
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
        { id: 99, name: 'jack', created_at: Time.current, updated_at: Time.current },
        { id: 100, name: 'kate', created_at: Time.current, updated_at: Time.current }
      ])

      assert accounts(:amazon), User.find(99)
      assert accounts(:amazon), User.find(100)
    end
  end

  test ".insert_all! - can't insert when tenant is missing" do
    assert_raise(MultiTenantSupport::MissingTenantError) do
      User.insert_all!([
        { id: 99, name: 'jack', created_at: Time.current, updated_at: Time.current },
        { id: 100, name: 'kate', created_at: Time.current, updated_at: Time.current }
      ])
    end
  end

  test ".insert_all! - can't insert when tenant is missing even allow read across tenant" do
    MultiTenantSupport.allow_read_across_tenant do
      assert_raise(MultiTenantSupport::MissingTenantError) do
        User.insert_all!([
          { id: 99, name: 'jack', created_at: Time.current, updated_at: Time.current },
          { id: 100, name: 'kate', created_at: Time.current, updated_at: Time.current }
        ])
      end
    end
  end

end
