require 'test_helper'

class MultiTenantSupport::ModelConcern::BelongsToTenant_CounterTest < ActiveSupport::TestCase

  test ".count - won't raise error on missing tenant when default scope is off" do
    MultiTenantSupport.allow_read_across_tenant do
      assert_equal 3, User.count
    end
  end

  test ".count - raise error on missing tenant when default scope is on" do
    MultiTenantSupport.disallow_read_across_tenant do
      assert_raise(MultiTenantSupport::MissingTenantError) { User.count }
    end
  end

  test ".count - won't count steve and zuck under amazon" do
    MultiTenantSupport.under_tenant accounts(:amazon) do
      assert_equal 1, User.count
    end
  end

  test ".count - won't count steve and zuck under amazon when wrap in allow_read_across_tenant " do
    MultiTenantSupport.allow_read_across_tenant do
      MultiTenantSupport.under_tenant accounts(:amazon) do
        assert_equal 1, User.count
      end
    end
  end

  test ".count - won't count steve and zuck under amazon when call allow_read_across_tenant withint it" do
    MultiTenantSupport.under_tenant accounts(:amazon) do
      MultiTenantSupport.allow_read_across_tenant do
        assert_equal 1, User.count
      end
    end
  end

end
