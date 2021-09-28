require 'test_helper'

class MultiTenantSupport::ModelConcernTest < ActiveSupport::TestCase

  setup do
    MultiTenantSupport.turn_default_scope_on
  end

  test '.belongs_to_tenant' do
    MultiTenantSupport.under_tenant accounts(:amazon) do
      assert_equal accounts(:amazon), users(:bezos).account
    end

    MultiTenantSupport.under_tenant accounts(:facebook) do
      assert_equal accounts(:facebook), users(:zuck).account
    end

    MultiTenantSupport.under_tenant accounts(:apple) do
      assert_equal accounts(:apple), users(:steve).account
    end
  end

  test 'can only initialize under correct tenant' do
    MultiTenantSupport.under_tenant accounts(:amazon) do
      users(:bezos)
      assert_raise(MultiTenantSupport::InvalidTenantAccess) {  users(:zuck) }
      assert_raise(MultiTenantSupport::InvalidTenantAccess) {  users(:steve) }
    end

    MultiTenantSupport.under_tenant accounts(:facebook) do
      assert_raise(MultiTenantSupport::InvalidTenantAccess) {  users(:bezos).reload }
      users(:zuck).reload
      assert_raise(MultiTenantSupport::InvalidTenantAccess) {  users(:steve).reload }
    end

    MultiTenantSupport.under_tenant accounts(:apple) do
      assert_raise(MultiTenantSupport::InvalidTenantAccess) {  users(:bezos).reload }
      assert_raise(MultiTenantSupport::InvalidTenantAccess) {  users(:zuck).reload }
      users(:steve).reload
    end
  end

  test '.belongs_to_tenant - set default scope to under current tenant when default scope is on' do
    MultiTenantSupport.under_tenant accounts(:amazon) do
      assert_equal 1, User.count
      assert_equal users(:bezos), User.first
      assert_equal users(:bezos), User.last
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
      assert_raise(MultiTenantSupport::MissingTenantError) { User.where(name: 'bezos') }
    end
  end

  test ".belongs_to_tenant - won't raise error when tenant is missing but default scope off" do
    MultiTenantSupport.turn_default_scope_off do
      assert_equal 3, User.count
    end
  end

  test "auto set tenant account on new and creation" do
    amazon = accounts(:amazon)
    MultiTenantSupport.under_tenant amazon do
      kate = User.new(name: 'kate')
      assert_equal amazon, kate.account
      assert kate.save
      assert_equal amazon, kate.account
    end
  end

  test "make tenant account to be a readonly association" do
    MultiTenantSupport.under_tenant accounts(:amazon) do
      assert_raise(MultiTenantSupport::ImmutableTenantError) { users(:bezos).account = accounts(:facebook) }
      assert_raise(MultiTenantSupport::ImmutableTenantError) { users(:bezos).account_id = accounts(:facebook).id }
      assert_raise(MultiTenantSupport::ImmutableTenantError) { users(:bezos).update(account: accounts(:facebook)) }
      assert_raise(MultiTenantSupport::ImmutableTenantError) { users(:bezos).update(account_id: accounts(:facebook).id) }
      assert_raise(MultiTenantSupport::ImmutableTenantError) { users(:bezos).update_attribute(:account, accounts(:facebook)) }
      assert_raise("account_id is marked as readonly") { users(:bezos).update_attribute(:account_id, accounts(:facebook).id) }
      assert_raise("account_id is marked as readonly") { users(:bezos).update_columns(account_id: accounts(:facebook).id) }
      assert_raise("account_id is marked as readonly") { users(:bezos).update_column(:account_id, accounts(:facebook).id) }

      assert_raise("account_id is marked as readonly") { users(:bezos).update_attribute(:account_id, nil) }
      assert_raise("account_id is marked as readonly") { users(:bezos).update_columns(account_id: nil) }
      assert_raise("account_id is marked as readonly") { users(:bezos).update_column(:account_id, nil) }
    end
  end

  test "tenant account cannot be nil" do
    MultiTenantSupport.under_tenant(accounts(:amazon)) do
      assert_raise(MultiTenantSupport::NilTenantError) { users(:bezos).account = nil }
      assert_raise(MultiTenantSupport::NilTenantError) { users(:bezos).account_id = nil }
      assert_raise(MultiTenantSupport::NilTenantError) { users(:bezos).update(account: nil) }
      assert_raise(MultiTenantSupport::NilTenantError) { users(:bezos).update(account_id: nil) }
      assert_raise(MultiTenantSupport::NilTenantError) { users(:bezos).update_attribute(:account, nil) }

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
    MultiTenantSupport.under_tenant accounts(:amazon) do
      assert_raise(MultiTenantSupport::InvalidTenantAccess) { users(:zuck) }
      assert_raise(MultiTenantSupport::InvalidTenantAccess) { User.unscoped.all.to_a }
    end
  end

  test "tenant's member model can only update when its tenant account match current tenant" do
    bezos = nil
    MultiTenantSupport.under_tenant accounts(:amazon) do
      bezos = users(:bezos)
      bezos.name = "JUFF BEZOS"
    end

    MultiTenantSupport.under_tenant accounts(:facebook) do
      assert_raise(MultiTenantSupport::InvalidTenantAccess) { bezos.save }
      assert_raise(MultiTenantSupport::InvalidTenantAccess) { bezos.save! }
      assert_raise(MultiTenantSupport::InvalidTenantAccess) { bezos.save(validate: false) }
      assert_raise(MultiTenantSupport::InvalidTenantAccess) { bezos.update(name: 'JUFF BEZOS') }
      assert_raise(MultiTenantSupport::InvalidTenantAccess) { bezos.update_attribute(:name, 'JUFF BEZOS') }
      assert_raise(MultiTenantSupport::InvalidTenantAccess) { bezos.update_columns(name: 'JUFF BEZOS') }
      assert_raise(MultiTenantSupport::InvalidTenantAccess) { bezos.update_column(:name, 'JUFF BEZOS') }
    end

    MultiTenantSupport.under_tenant accounts(:amazon) do
      bezos.reload
      assert_equal "Jeff Bezos", bezos.name
    end
  end

end
