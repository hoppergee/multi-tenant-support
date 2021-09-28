require 'test_helper'

class MultiTenantSupport::ModelConcern::BelongsToTenant_FinderTest < ActiveSupport::TestCase

  test "won't raise error on missing tenant when default scope is off" do
    MultiTenantSupport.turn_default_scope_off do
      refute User.first.nil?
      refute User.last.nil?
      refute User.where(name: 'Jeff Bezos').first.nil?
      refute User.find_by(name: 'Mark Zuckerberg').nil?
    end
  end

  test "raise error on missing tenant when default scope is on" do
    MultiTenantSupport.turn_default_scope_on do
      assert_raise(MultiTenantSupport::MissingTenantError) { User.first }
      assert_raise(MultiTenantSupport::MissingTenantError) { User.last }
      assert_raise(MultiTenantSupport::MissingTenantError) { User.where(name: 'Jeff Bezos') }
      assert_raise(MultiTenantSupport::MissingTenantError) { User.find_by(name: 'Mark Zuckerberg') }
    end
  end

end
