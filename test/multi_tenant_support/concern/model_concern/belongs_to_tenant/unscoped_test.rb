require 'test_helper'

class MultiTenantSupport::ModelConcern::BelongsToTenant_UnscopedTest < ActiveSupport::TestCase

  test ".unscoped - raise error when disallow read across tenant (default)" do
    MultiTenantSupport.under_tenant accounts(:amazon) do
      assert_raise(MultiTenantSupport::InvalidTenantAccess) { User.unscoped.all.to_a }
    end
  end

  test ".unscoped - won't raise error when allow read across tenant" do
    MultiTenantSupport.allow_read_across_tenant do
      MultiTenantSupport.under_tenant accounts(:amazon) do
        assert_equal 3, User.unscoped.all.to_a.count
      end
    end
  end

end