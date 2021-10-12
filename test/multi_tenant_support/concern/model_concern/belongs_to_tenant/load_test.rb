require 'test_helper'

class MultiTenantSupport::ModelConcern::BelongsToTenant_LoadTest < ActiveSupport::TestCase

  test 'bezos can only initialize under amazon' do
    MultiTenantSupport.under_tenant accounts(:amazon) do
      users(:bezos).reload
    end

    MultiTenantSupport.under_tenant accounts(:facebook) do
      assert_raise(ActiveRecord::RecordNotFound) {  users(:bezos).reload }
    end

    MultiTenantSupport.under_tenant accounts(:apple) do
      assert_raise(ActiveRecord::RecordNotFound) {  users(:bezos).reload }
    end
  end

  test 'zuck can only initialize under facebook' do
    MultiTenantSupport.under_tenant accounts(:amazon) do
      assert_raise(ActiveRecord::RecordNotFound) {  users(:zuck).reload }
    end

    MultiTenantSupport.under_tenant accounts(:facebook) do
      users(:zuck).reload
    end

    MultiTenantSupport.under_tenant accounts(:apple) do
      assert_raise(ActiveRecord::RecordNotFound) {  users(:zuck).reload }
    end
  end

  test 'steve can only initialize under apple' do
    MultiTenantSupport.under_tenant accounts(:amazon) do
      assert_raise(ActiveRecord::RecordNotFound) {  users(:steve).reload }
    end

    MultiTenantSupport.under_tenant accounts(:facebook) do
      assert_raise(ActiveRecord::RecordNotFound) {  users(:steve).reload }
    end

    MultiTenantSupport.under_tenant accounts(:apple) do
      users(:steve).reload
    end
  end

  test 'initialize works for all users when allow_read_across_tennat' do
    allow_read_across_tenant do
      users(:steve).reload
      users(:bezos).reload
      users(:zuck).reload
    end
  end

  test 'initialize works for all users when turn off protection' do
    turn_off_protection do
      users(:steve).reload
      users(:bezos).reload
      users(:zuck).reload
    end
  end

end