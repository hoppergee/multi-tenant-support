require 'test_helper'

class MultiTenantSupport::ModelConcern::BelongsToTenant_CreateTest < ActiveSupport::TestCase

  ####
  # .save, .create, .create!, .insert and insert!
  ####
  test "create/insert - auto set tenant account on creation" do
    MultiTenantSupport.under_tenant accounts(:amazon) do
      kate = User.new(name: 'kate')
      assert kate.save
      assert_equal accounts(:amazon), kate.account

      assert_difference 'User.count', 1 do
        john = User.create(name: 'john')
        assert_equal accounts(:amazon), john.account
      end

      jack = User.create!(name: 'jack')
      assert_equal accounts(:amazon), jack.account

      assert_difference 'User.count', 1 do
        User.insert({name: 'tom', created_at: Time.current, updated_at: Time.current})
        assert_equal accounts(:amazon), User.find_by(name: 'tom').account
      end

      assert_difference 'User.count', 1 do
        User.insert!({name: 'robin', created_at: Time.current, updated_at: Time.current})
        assert_equal accounts(:amazon), User.find_by(name: 'robin').account
      end
    end
  end

  test "create/insert - raise error on missing tenant when not allow read across tenant (default)" do
    assert_raise(MultiTenantSupport::MissingTenantError) { User.create(email: 'test@test.com') }
    assert_raise(MultiTenantSupport::MissingTenantError) { User.create!(email: 'test@test.com') }
    assert_raise(MultiTenantSupport::MissingTenantError) do
      u = User.new(email: 'test@test.com')
      u.save
    end
    assert_raise(MultiTenantSupport::MissingTenantError) { User.insert({email: 'test@test.com'}) }
    assert_raise(MultiTenantSupport::MissingTenantError) { User.insert!({email: 'test@test.com'}) }
  end

  test "create/insert - raise error on missing tenant when allow read across tenant" do
    MultiTenantSupport.allow_read_across_tenant do
      assert_raise(MultiTenantSupport::MissingTenantError) { User.create(email: 'test@test.com') }
      assert_raise(MultiTenantSupport::MissingTenantError) { User.create!(email: 'test@test.com') }
      assert_raise(MultiTenantSupport::MissingTenantError) do
        u = User.new(email: 'test@test.com')
        u.save
      end
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
