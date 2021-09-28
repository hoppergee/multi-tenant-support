require 'test_helper'

class MultiTenantSupport::ModelConcern::BelongsToTenant_CreateTest < ActiveSupport::TestCase

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

end
