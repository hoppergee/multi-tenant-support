require 'test_helper'

class MultiTenantSupport::ModelConcernTest < ActiveSupport::TestCase

  setup do
    MultiTenantSupport.turn_default_scope_on
  end

  test '.belongs_to_tenant' do
    MultiTenantSupport.under_tenant accounts(:beer_stark) do
      assert_equal accounts(:beer_stark), users(:jack).account
    end

    MultiTenantSupport.under_tenant accounts(:fisher_mante) do
      assert_equal accounts(:fisher_mante), users(:william).account
    end

    MultiTenantSupport.under_tenant accounts(:kohler) do
      assert_equal accounts(:kohler), users(:robin).account
    end
  end

  test 'can only initialize under correct tenant' do
    MultiTenantSupport.under_tenant accounts(:beer_stark) do
      users(:jack)
      assert_raise(MultiTenantSupport::InvalidTenantAccess) {  users(:william) }
      assert_raise(MultiTenantSupport::InvalidTenantAccess) {  users(:robin) }
    end

    MultiTenantSupport.under_tenant accounts(:fisher_mante) do
      assert_raise(MultiTenantSupport::InvalidTenantAccess) {  users(:jack).reload }
      users(:william).reload
      assert_raise(MultiTenantSupport::InvalidTenantAccess) {  users(:robin).reload }
    end

    MultiTenantSupport.under_tenant accounts(:kohler) do
      assert_raise(MultiTenantSupport::InvalidTenantAccess) {  users(:jack).reload }
      assert_raise(MultiTenantSupport::InvalidTenantAccess) {  users(:william).reload }
      users(:robin).reload
    end
  end

  test '.belongs_to_tenant - set default scope to under current tenant when default scope is on' do
    MultiTenantSupport.under_tenant accounts(:beer_stark) do
      assert_equal 1, User.count
      assert_equal users(:jack), User.first
      assert_equal users(:jack), User.last
      kate = User.new(name: 'kate')
      assert kate.save
      assert_equal kate, User.where(name: 'kate').first
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
    beer_stark = accounts(:beer_stark)
    MultiTenantSupport.under_tenant beer_stark do
      kate = User.new(name: 'kate')
      assert_equal beer_stark, kate.account
      assert kate.save
      assert_equal beer_stark, kate.account
    end
  end

  test "make tenant account to be a readonly association" do
    MultiTenantSupport.under_tenant accounts(:beer_stark) do
      assert_raise(MultiTenantSupport::ImmutableTenantError) { users(:jack).account = accounts(:fisher_mante) }
      assert_raise(MultiTenantSupport::ImmutableTenantError) { users(:jack).account_id = accounts(:fisher_mante).id }
      assert_raise(MultiTenantSupport::ImmutableTenantError) { users(:jack).update(account: accounts(:fisher_mante)) }
      assert_raise(MultiTenantSupport::ImmutableTenantError) { users(:jack).update(account_id: accounts(:fisher_mante).id) }
      assert_raise(MultiTenantSupport::ImmutableTenantError) { users(:jack).update_attribute(:account, accounts(:fisher_mante)) }
      assert_raise("account_id is marked as readonly") { users(:jack).update_attribute(:account_id, accounts(:fisher_mante).id) }
      assert_raise("account_id is marked as readonly") { users(:jack).update_columns(account_id: accounts(:fisher_mante).id) }
      assert_raise("account_id is marked as readonly") { users(:jack).update_column(:account_id, accounts(:fisher_mante).id) }

      assert_raise("account_id is marked as readonly") { users(:jack).update_attribute(:account_id, nil) }
      assert_raise("account_id is marked as readonly") { users(:jack).update_columns(account_id: nil) }
      assert_raise("account_id is marked as readonly") { users(:jack).update_column(:account_id, nil) }
    end
  end

  test "tenant account cannot be nil" do
    MultiTenantSupport.under_tenant(accounts(:beer_stark)) do
      assert_raise(MultiTenantSupport::NilTenantError) { users(:jack).account = nil }
      assert_raise(MultiTenantSupport::NilTenantError) { users(:jack).account_id = nil }
      assert_raise(MultiTenantSupport::NilTenantError) { users(:jack).update(account: nil) }
      assert_raise(MultiTenantSupport::NilTenantError) { users(:jack).update(account_id: nil) }
      assert_raise(MultiTenantSupport::NilTenantError) { users(:jack).update_attribute(:account, nil) }

      user = User.new
      assert_raise(MultiTenantSupport::NilTenantError) { user.account = nil }
      assert_raise(MultiTenantSupport::NilTenantError) { user.account_id = nil }
    end
  end

  test "tenant account binding object cannot be initialize when current tenant is nil" do
    MultiTenantSupport::Current.tenant_account = nil
    assert_raise(MultiTenantSupport::MissingTenantError) { User.new }
  end

  test "tenant's member model can only initialize when its tenant account match current tenant" do
    MultiTenantSupport.under_tenant accounts(:beer_stark) do
      assert_raise(MultiTenantSupport::InvalidTenantAccess) { users(:william) }
      assert_raise(MultiTenantSupport::InvalidTenantAccess) { User.unscoped.all.to_a }
    end
  end

end
