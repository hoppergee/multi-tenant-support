require 'test_helper'

class MultiTenantSupport::ModelConcern::BelongsToTenant_UpdateTest < ActiveSupport::TestCase

  setup do
    MultiTenantSupport.under_tenant accounts(:amazon) do
      @bezos = users(:bezos)
    end
  end

  test 'update - can update user when user.account match current tenant' do
    MultiTenantSupport.under_tenant accounts(:amazon) do
      @bezos.name = "JUFF BEZOS"
      assert @bezos.save
      assert_equal "JUFF BEZOS", @bezos.name
    end
  end

  test "raise error on update through .save when user.account not matching current tenant" do
    @bezos.name = "JUFF BEZOS"

    MultiTenantSupport.under_tenant accounts(:facebook) do
      assert_raise(MultiTenantSupport::InvalidTenantAccess) { @bezos.save }
    end

    MultiTenantSupport.under_tenant accounts(:amazon) do
      @bezos.reload
      assert_equal "Jeff Bezos", @bezos.name
    end
  end

  test "raise error on update through .save! when user.account not matching current tenant" do
    @bezos.name = "JUFF BEZOS"
    MultiTenantSupport.under_tenant accounts(:facebook) do
      assert_raise(MultiTenantSupport::InvalidTenantAccess) { @bezos.save! }
    end

    MultiTenantSupport.under_tenant accounts(:amazon) do
      @bezos.reload
      assert_equal "Jeff Bezos", @bezos.name
    end
  end

  test "raise error on update through .save(validate: false) when user.account not matching current tenant" do
    @bezos.name = "JUFF BEZOS"
    MultiTenantSupport.under_tenant accounts(:facebook) do
      assert_raise(MultiTenantSupport::InvalidTenantAccess) { @bezos.save(validate: false) }
    end

    MultiTenantSupport.under_tenant accounts(:amazon) do
      @bezos.reload
      assert_equal "Jeff Bezos", @bezos.name
    end
  end

  test "raise error on update through update when user.account not matching current tenant" do
    MultiTenantSupport.under_tenant accounts(:facebook) do
      assert_raise(MultiTenantSupport::InvalidTenantAccess) { @bezos.update(name: 'JUFF BEZOS') }
    end

    MultiTenantSupport.under_tenant accounts(:amazon) do
      @bezos.reload
      assert_equal "Jeff Bezos", @bezos.name
    end
  end

  test "raise error on update through update_attribute when user.account not matching current tenant" do
    MultiTenantSupport.under_tenant accounts(:facebook) do
      assert_raise(MultiTenantSupport::InvalidTenantAccess) { @bezos.update_attribute(:name, 'JUFF BEZOS') }
    end

    MultiTenantSupport.under_tenant accounts(:amazon) do
      @bezos.reload
      assert_equal "Jeff Bezos", @bezos.name
    end
  end

  test "raise error on update through update_columns when user.account not matching current tenant" do
    MultiTenantSupport.under_tenant accounts(:facebook) do
      assert_raise(MultiTenantSupport::InvalidTenantAccess) { @bezos.update_columns(name: 'JUFF BEZOS') }
    end

    MultiTenantSupport.under_tenant accounts(:amazon) do
      @bezos.reload
      assert_equal "Jeff Bezos", @bezos.name
    end
  end

  test "raise error on update through update_column when user.account not matching current tenant" do
    MultiTenantSupport.under_tenant accounts(:facebook) do
      assert_raise(MultiTenantSupport::InvalidTenantAccess) { @bezos.update_column(:name, 'JUFF BEZOS') }
    end

    MultiTenantSupport.under_tenant accounts(:amazon) do
      @bezos.reload
      assert_equal "Jeff Bezos", @bezos.name
    end
  end

  test "raise error on update through .save when missing current tenant and allow read across tenant" do
    @bezos.name = "JUFF BEZOS"

    MultiTenantSupport.turn_default_scope_off do
      assert_raise(MultiTenantSupport::InvalidTenantAccess) { @bezos.save }

      @bezos.reload
      assert_equal "Jeff Bezos", @bezos.name
    end
  end

  test "raise error on update through .save! when missing current tenant and allow read across tenant" do
    @bezos.name = "JUFF BEZOS"

    MultiTenantSupport.turn_default_scope_off do
      assert_raise(MultiTenantSupport::InvalidTenantAccess) { @bezos.save! }

      @bezos.reload
      assert_equal "Jeff Bezos", @bezos.name
    end
  end

  test "raise error on update through .save(validate: false) when missing current tenant and allow read across tenant" do
    @bezos.name = "JUFF BEZOS"

    MultiTenantSupport.turn_default_scope_off do
      assert_raise(MultiTenantSupport::InvalidTenantAccess) { @bezos.save(validate: false) }

      @bezos.reload
      assert_equal "Jeff Bezos", @bezos.name
    end
  end

  test "raise error on update through update when missing current tenant and allow read across tenant" do
    MultiTenantSupport.turn_default_scope_off do
      assert_raise(MultiTenantSupport::InvalidTenantAccess) { @bezos.update(name: 'JUFF BEZOS') }

      @bezos.reload
      assert_equal "Jeff Bezos", @bezos.name
    end
  end

  test "raise error on update through update_attribute when missing current tenant and allow read across tenant" do
    MultiTenantSupport.turn_default_scope_off do
      assert_raise(MultiTenantSupport::InvalidTenantAccess) { @bezos.update_attribute(:name, 'JUFF BEZOS') }

      @bezos.reload
      assert_equal "Jeff Bezos", @bezos.name
    end
  end

  test "raise error on update through update_columns when missing current tenant and allow read across tenant" do
    MultiTenantSupport.turn_default_scope_off do
      assert_raise(MultiTenantSupport::InvalidTenantAccess) { @bezos.update_columns(name: 'JUFF BEZOS') }

      @bezos.reload
      assert_equal "Jeff Bezos", @bezos.name
    end
  end

  test "raise error on update through update_column when missing current tenant and allow read across tenant" do
    MultiTenantSupport.turn_default_scope_off do
      assert_raise(MultiTenantSupport::InvalidTenantAccess) { @bezos.update_column(:name, 'JUFF BEZOS') }

      @bezos.reload
      assert_equal "Jeff Bezos", @bezos.name
    end
  end

end
