require 'test_helper'

class MultiTenantSupport::ModelConcern::BelongsToTenant_DefaultScopeSetupTest < ActiveSupport::TestCase

  setup do
    MultiTenantSupport.disallow_read_across_tenant
  end

  test 'set default scope to under current tenant' do
    MultiTenantSupport.under_tenant accounts(:amazon) do
      assert_equal 1, User.all.to_a.count
      assert_equal 1, User.count
      assert_equal users(:bezos), User.first
      assert_equal users(:bezos), User.last
      assert_equal users(:bezos), User.find_by(name: 'Jeff Bezos')
      assert_equal users(:bezos), User.where(name: 'Jeff Bezos').first
      kate = User.new(name: 'kate')
      assert kate.save
      assert_equal kate, User.where(name: 'kate').first
    end
  end

  test 'raise error when tenant is missing' do
    assert_raise(MultiTenantSupport::MissingTenantError) { User.all }
    assert_raise(MultiTenantSupport::MissingTenantError) { User.count }
    assert_raise(MultiTenantSupport::MissingTenantError) { User.first }
    assert_raise(MultiTenantSupport::MissingTenantError) { User.last }
    assert_raise(MultiTenantSupport::MissingTenantError) { User.new }
    assert_raise(MultiTenantSupport::MissingTenantError) { User.create(email: 'test@test.com') }
    assert_raise(MultiTenantSupport::MissingTenantError) { User.where(name: 'bezos') }
    assert_raise(MultiTenantSupport::MissingTenantError) { User.find_by(name: 'bezos') }
  end

end