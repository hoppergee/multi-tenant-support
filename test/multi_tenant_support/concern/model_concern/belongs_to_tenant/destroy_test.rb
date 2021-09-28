require 'test_helper'

class MultiTenantSupport::ModelConcern::BelongsToTenant_DestroyProtectTest < ActiveSupport::TestCase

  setup do
    MultiTenantSupport.under_tenant accounts(:amazon) do
      @bezos = users(:bezos)
    end
  end

  test 'protect #destroy' do
    MultiTenantSupport.under_tenant accounts(:facebook) do
      assert_raise(MultiTenantSupport::InvalidTenantAccess) { @bezos.destroy }
    end

    MultiTenantSupport.under_tenant accounts(:amazon) do
      assert @bezos.reload.persisted?
    end
  end

  test 'protect #destroy!' do
    MultiTenantSupport.under_tenant accounts(:facebook) do
      assert_raise(MultiTenantSupport::InvalidTenantAccess) { @bezos.destroy! }
    end

    MultiTenantSupport.under_tenant accounts(:amazon) do
      assert @bezos.reload.persisted?
    end
  end

  test "protect .destroy_all" do
    MultiTenantSupport.under_tenant accounts(:facebook) do
      assert_changes "User.unscope_tenant.count", from: 3, to: 2 do
        User.destroy_all
      end
    end
  end

  test "protect .destroy_by" do
    MultiTenantSupport.under_tenant accounts(:facebook) do
      assert_no_difference "User.unscope_tenant.count" do
        User.destroy_by(name: 'bezos')
      end

      assert_equal 3, User.unscope_tenant.count
    end
  end

  test "protect .delete_all" do
    MultiTenantSupport.under_tenant accounts(:facebook) do
      assert_changes "User.unscope_tenant.count", from: 3, to: 2 do
        User.delete_all
      end
    end
  end

  test "protect .delete_by" do
    MultiTenantSupport.under_tenant accounts(:facebook) do
      assert_no_difference "User.unscope_tenant.count" do
        User.delete_by(name: 'bezos')
      end

      assert_equal 3, User.unscope_tenant.count
    end
  end

end
