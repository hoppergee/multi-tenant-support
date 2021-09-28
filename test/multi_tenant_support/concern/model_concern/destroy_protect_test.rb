require 'test_helper'

class MultiTenantSupport::ModelConcern::DestroyProtectTest < ActiveSupport::TestCase

  setup do
    MultiTenantSupport.under_tenant accounts(:beer_stark) do
      @jack = users(:jack)
    end
  end

  test 'protect #destroy' do
    MultiTenantSupport.under_tenant accounts(:fisher_mante) do
      assert_raise(MultiTenantSupport::InvalidTenantAccess) { @jack.destroy }
    end

    MultiTenantSupport.under_tenant accounts(:beer_stark) do
      assert @jack.reload.persisted?
    end
  end

  test 'protect #destroy!' do
    MultiTenantSupport.under_tenant accounts(:fisher_mante) do
      assert_raise(MultiTenantSupport::InvalidTenantAccess) { @jack.destroy! }
    end

    MultiTenantSupport.under_tenant accounts(:beer_stark) do
      assert @jack.reload.persisted?
    end
  end

  test "protect .destroy_all" do
    MultiTenantSupport.under_tenant accounts(:fisher_mante) do
      assert_changes "User.unscope_tenant.count", from: 3, to: 2 do
        User.destroy_all
      end
    end
  end

  test "protect .destroy_by" do
    MultiTenantSupport.under_tenant accounts(:fisher_mante) do
      assert_no_difference "User.unscope_tenant.count" do
        User.destroy_by(name: 'jack')
      end

      assert_equal 3, User.unscope_tenant.count
    end
  end

  test "protect .delete_all" do
    MultiTenantSupport.under_tenant accounts(:fisher_mante) do
      assert_changes "User.unscope_tenant.count", from: 3, to: 2 do
        User.delete_all
      end
    end
  end

  test "protect .delete_by" do
    MultiTenantSupport.under_tenant accounts(:fisher_mante) do
      assert_no_difference "User.unscope_tenant.count" do
        User.delete_by(name: 'jack')
      end

      assert_equal 3, User.unscope_tenant.count
    end
  end

end
