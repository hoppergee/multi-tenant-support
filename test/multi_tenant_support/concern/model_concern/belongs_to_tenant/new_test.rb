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
    MultiTenantSupport.allow_read_across_tenant do
      assert_raise(MultiTenantSupport::MissingTenantError) do
        User.new
      end

      assert_raise(MultiTenantSupport::MissingTenantError) do
        accounts(:amazon).users.build
      end
    end
  end

  test ".new - auto set tenant account on new when super admin manual set current tenant" do
    allow_read_across_tenant do
      under_tenant amazon do
        kate = User.new(name: 'kate')
        assert_equal amazon, kate.account

        john = tags(:engineer).users.build
        assert_equal amazon, john.account
      end
    end
  end

  test ".new - success without auto set tenant account on new when turn off protection" do
    turn_off_protection do
      kate = User.new(name: 'kate')
      assert kate.account.nil?

      john = tags(:engineer).users.build
      assert john.account.nil?
    end
  end

end