require 'test_helper'

class MultiTenantSupport::ModelConcern::BelongsToTenant_FinderTest < ActiveSupport::TestCase

  test "won't raise error on missing tenant when all read across tennat" do
    allow_read_across_tenant do
      refute User.first.nil?
      refute User.last.nil?
      refute User.where(name: 'Jeff Bezos').first.nil?
      refute User.find_by(name: 'Mark Zuckerberg').nil?
    end
  end

  test "raise error on missing tenant when turn on full protection" do
    turn_on_full_protection do
      assert_raise(MultiTenantSupport::MissingTenantError) { User.first }
      assert_raise(MultiTenantSupport::MissingTenantError) { User.last }
      assert_raise(MultiTenantSupport::MissingTenantError) { User.where(name: 'Jeff Bezos') }
      assert_raise(MultiTenantSupport::MissingTenantError) { User.find_by(name: 'Mark Zuckerberg') }
    end
  end

  test "won't raise error on missing tenant when turn off protection" do
    turn_off_protection do
      refute User.first.nil?
      refute User.last.nil?
      refute User.where(name: 'Jeff Bezos').first.nil?
      refute User.find_by(name: 'Mark Zuckerberg').nil?
    end
  end

end
