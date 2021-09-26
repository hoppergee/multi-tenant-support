require 'test_helper'

class MultiTenantSupport::ModelConcernTest < ActiveSupport::TestCase

  test '.belongs_to_tenant' do
    assert_equal accounts(:beer_stark), users(:jack).account
    assert_equal accounts(:fisher_mante), users(:william).account
    assert_equal accounts(:kohler), users(:robin).account
  end

  test '.belongs_to_tenant - set default scope to under current tenant' do
    MultiTenantSupport.under_tenant accounts(:beer_stark) do
      assert_equal 3, User.unscope_tenant.count
      assert_equal 1, User.count
      assert_equal users(:jack), User.first
      assert_equal users(:jack), User.last
      kate = User.new(name: 'kate')
      assert kate.save
      assert_equal kate, User.where(name: 'kate').first
    end
  end

  test '.belongs_to_tenant - raise error when tenant is missing' do
    assert_raise("Current tenant is missing") { User.count }
    assert_raise("Current tenant is missing") { User.first }
    assert_raise("Current tenant is missing") { User.last }
    assert_raise("Current tenant is missing") { User.new }
    assert_raise("Current tenant is missing") { User.create(email: 'test@test.com') }
    assert_raise("Current tenant is missing") { User.where(name: 'jack') }
  end

end
