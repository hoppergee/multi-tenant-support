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
      assert_raise(ActiveRecord::RecordNotFound) {  users(:zuck) }
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

end