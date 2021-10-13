require 'test_helper'


class ModelDeleteAllOnGlobalRecordsProtectTest < ActiveSupport::TestCase

  ####
  # .delete_all on global records like account, tag, country ...
  ####
  test "can delete_all global records by a tenant" do
    within_a_request_of amazon do
      assert_delete_all_on_global_records(-3)
    end
  end

  test "can delete_all global records when the tenant is missing" do
    turn_on_full_protection do
      missing_tenant do
        assert_delete_all_on_global_records(-3)
      end
    end
  end

  test 'can delete_all global records by super admin' do
    within_a_request_of super_admin do
      assert_delete_all_on_global_records(-3)
    end
  end

  test 'can delete_all global records by super admin event manual set current tenant' do
    within_a_request_of super_admin do
      under_tenant amazon do
        assert_delete_all_on_global_records(-3)
      end
    end
  end

  test 'can delete_all global records by super admin event manual turn off protection' do
    within_a_request_of super_admin do
      turn_off_protection do
        assert_delete_all_on_global_records(-3)
      end
    end
  end

  private

  def assert_delete_all_on_global_records(number_change)
    assert_difference "Account.count", number_change do
      Account.delete_all
    end
  end

end
