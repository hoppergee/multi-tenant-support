require 'test_helper'

class MultiTenantSupport::ModelConcernTest < ActiveSupport::TestCase

  test '.belongs_to_tenant' do
    assert_equal accounts(:beer_stark), users(:jack).account
    assert_equal accounts(:fisher_mante), users(:william).account
    assert_equal accounts(:kohler), users(:robin).account
  end

  test '.belongs_to_tenant - set default scope to under current tenant when default scope is on' do
    MultiTenantSupport.turn_default_scope_on do
      MultiTenantSupport.under_tenant accounts(:beer_stark) do
        assert_equal 1, User.count
        assert_equal users(:jack), User.first
        assert_equal users(:jack), User.last
        kate = User.new(name: 'kate')
        assert kate.save
        assert_equal kate, User.where(name: 'kate').first
      end
    end
  end

  test '.belongs_to_tenant - raise error when tenant is missing and default scope on' do
    MultiTenantSupport.turn_default_scope_on do
      assert_raise(MultiTenantSupport::MissingTenantError) { User.count }
      assert_raise(MultiTenantSupport::MissingTenantError) { User.first }
      assert_raise(MultiTenantSupport::MissingTenantError) { User.last }
      assert_raise(MultiTenantSupport::MissingTenantError) { User.new }
      assert_raise(MultiTenantSupport::MissingTenantError) { User.create(email: 'test@test.com') }
      assert_raise(MultiTenantSupport::MissingTenantError) { User.where(name: 'jack') }
    end
  end

  test ".belongs_to_tenant - won't raise error when tenant is missing but default scope off" do
    MultiTenantSupport.turn_default_scope_off do
      assert_equal 3, User.count
    end
  end

  test "auto set tenant account on new and creation" do
    MultiTenantSupport.turn_default_scope_on do
      beer_stark = accounts(:beer_stark)
      MultiTenantSupport.under_tenant beer_stark do
        kate = User.new(name: 'kate')
        assert_equal beer_stark, kate.account
        assert kate.save
        assert_equal beer_stark, kate.account
      end
    end
  end

end
