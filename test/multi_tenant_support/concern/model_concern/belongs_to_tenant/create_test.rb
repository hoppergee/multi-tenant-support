require 'test_helper'

class MultiTenantSupport::ModelConcern::BelongsToTenant_CreateTest < ActiveSupport::TestCase

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
