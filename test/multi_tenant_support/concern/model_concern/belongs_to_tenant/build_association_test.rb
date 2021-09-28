require 'test_helper'

class MultiTenantSupport::ModelConcern::BelongsToTenant_BuildAssociationTest < ActiveSupport::TestCase

  test 'bezos.account is amazon' do
    MultiTenantSupport.under_tenant accounts(:amazon) do
      assert_equal accounts(:amazon), users(:bezos).account
    end
  end

  test 'zuck.account is facebook' do
    MultiTenantSupport.under_tenant accounts(:facebook) do
      assert_equal accounts(:facebook), users(:zuck).account
    end
  end

  test 'steve.account is apple' do
    MultiTenantSupport.under_tenant accounts(:apple) do
      assert_equal accounts(:apple), users(:steve).account
    end
  end

end
