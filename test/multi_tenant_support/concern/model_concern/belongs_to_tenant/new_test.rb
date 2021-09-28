require 'test_helper'

class MultiTenantSupport::ModelConcern::BelongsToTenant_NewTest < ActiveSupport::TestCase

  test ".new - auto set tenant account on new" do
    MultiTenantSupport.under_tenant accounts(:amazon) do
      kate = User.new(name: 'kate')
      assert_equal accounts(:amazon), kate.account
    end
  end

  test ".new - raise error on missing tenant missing when not allow read across tenant (default)" do
    assert_raise(MultiTenantSupport::MissingTenantError) do
      User.new
    end
  end

  test ".new - raise error on missing tenant when allow read across tenant" do
    MultiTenantSupport.turn_default_scope_off do
      assert_raise(MultiTenantSupport::MissingTenantError) do
        User.new
      end

      assert_raise(MultiTenantSupport::MissingTenantError) do
        accounts(:amazon).users.build
      end
    end
  end

end