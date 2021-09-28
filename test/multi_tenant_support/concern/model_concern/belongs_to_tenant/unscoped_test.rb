require 'test_helper'

class MultiTenantSupport::ModelConcern::BelongsToTenant_UnscopedTest < ActiveSupport::TestCase

  test ".unscoped - won't scope other tenants' records when disallow read across tenant (default) and current tenant exits" do
    MultiTenantSupport.under_tenant accounts(:amazon) do
      assert_equal 1, User.unscoped.count
    end
  end

  test ".unscoped - raise error when disallow read across tenant (default) and missing current tenant" do
    assert_raise(MultiTenantSupport::MissingTenantError) { User.unscoped.count }
  end

  test ".unscoped - won't scope other tenants' records when allow read across tenant (default) and current tenant exits" do
    MultiTenantSupport.allow_read_across_tenant do
      MultiTenantSupport.under_tenant accounts(:amazon) do
        assert_equal 1, User.unscoped.count
      end
    end
  end

  test ".unscoped - scope all tenants' records when allow read across tenant (default) and missing current tenant" do
    MultiTenantSupport.allow_read_across_tenant do
      assert_equal 3, User.where(name: 'Jeff Bezos').unscoped.count
    end
  end

end