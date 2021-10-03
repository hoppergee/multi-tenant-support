require 'test_helper'

class MultiTenantSupport::ModelConcern::BelongsToTenant_UpdateTest < ActiveSupport::TestCase

  setup do
    MultiTenantSupport.under_tenant accounts(:amazon) do
      @bezos = users(:bezos)
    end
  end

  ####
  # .update_all
  ####
  test ".update_all - won't succes when tenant is missing" do
    assert_raise MultiTenantSupport::MissingTenantError do
      User.update_all(name: 'NAME')
    end

    MultiTenantSupport.allow_read_across_tenant do
      refute User.pluck(:name).include?('NAME')
    end

    MultiTenantSupport.allow_read_across_tenant do
      assert_raise MultiTenantSupport::MissingTenantError do
        User.update_all(name: 'NAME')
      end
    end

    MultiTenantSupport.allow_read_across_tenant do
      refute User.pluck(:name).include?('NAME')
    end
  end

  test ".update_all - can success update when tenant exist" do
    MultiTenantSupport.under_tenant accounts(:apple) do
      User.update_all(name: 'NAME')
    end

    MultiTenantSupport.allow_read_across_tenant do
      assert_equal 3, User.count
      assert_equal 1, User.where(name: 'NAME').count
    end
  end

end
