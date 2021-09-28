require 'test_helper'

class MultiTenantSupport::ModelConcern::BelongsToTenant_CounterTest < ActiveSupport::TestCase

  test ".count - won't raise error on missing tenant when default scope is off" do
    MultiTenantSupport.turn_default_scope_off do
      assert_equal 3, User.count
    end
  end

  test ".count - raise error on missing tenant when default scope is on" do
    MultiTenantSupport.turn_default_scope_on do
      assert_raise(MultiTenantSupport::MissingTenantError) { User.count }
    end
  end

  test ".count - won't count steve and zuck under amazon" do
    MultiTenantSupport.under_tenant accounts(:amazon) do
      assert_equal 1, User.count
    end
  end

end
