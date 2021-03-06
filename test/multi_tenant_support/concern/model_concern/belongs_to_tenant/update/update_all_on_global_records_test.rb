require 'test_helper'


class ModelUpdateAllOnGlobalRecordsProtectTest < ActiveSupport::TestCase

  ####
  #     #update_all on global records
  ####
  test "can update_all global records by tenant" do
    within_a_request_of amazon do
      assert_update_all_on_global_records affect: 2
    end
  end

  test "can update_all global records even the tenant is missing" do
    turn_on_full_protection do
      missing_tenant do
        assert_update_all_on_global_records affect: 2
      end
    end
  end

  test 'can update_all global records by super admin' do
    within_a_request_of super_admin do
      assert_update_all_on_global_records affect: 2
    end
  end

  test 'can update_all global records by super admin even manual set current tenant' do
    within_a_request_of super_admin do
      under_tenant amazon do
        assert_update_all_on_global_records affect: 2
      end
    end
  end

  test 'can update_all global records by super admin even manual turn off protection' do
    within_a_request_of super_admin do
      turn_off_protection do
        assert_update_all_on_global_records affect: 2
      end
    end
  end

  private

  def assert_update_all_on_global_records(affect:)
    Tag.update_all(name: 'NEW TAG NAME')

    as_super_admin do
      without_current_tenant do
        assert_equal affect, Tag.where(name: 'NEW TAG NAME').count
      end
    end
  end

end
