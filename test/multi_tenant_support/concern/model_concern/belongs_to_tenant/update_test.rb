require 'test_helper'

class MultiTenantSupport::ModelConcern::BelongsToTenant_UpdateTest < ActiveSupport::TestCase

  setup do
    MultiTenantSupport.under_tenant accounts(:amazon) do
      @bezos = users(:bezos)
    end
  end

  ####
  # .save
  ####
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

  test "raise error on update through .save when missing current tenant and allow read across tenant" do
    @bezos.name = "JUFF BEZOS"

    MultiTenantSupport.allow_read_across_tenant do
      assert_raise(MultiTenantSupport::InvalidTenantAccess) { @bezos.save }

      @bezos.reload
      assert_equal "Jeff Bezos", @bezos.name
    end
  end

  ####
  # .save!
  ####
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

  test "raise error on update through .save! when missing current tenant and allow read across tenant" do
    @bezos.name = "JUFF BEZOS"

    MultiTenantSupport.allow_read_across_tenant do
      assert_raise(MultiTenantSupport::InvalidTenantAccess) { @bezos.save! }

      @bezos.reload
      assert_equal "Jeff Bezos", @bezos.name
    end
  end

  ####
  # .save(validate: false)
  ####
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

  test "raise error on update through .save(validate: false) when missing current tenant and allow read across tenant" do
    @bezos.name = "JUFF BEZOS"

    MultiTenantSupport.allow_read_across_tenant do
      assert_raise(MultiTenantSupport::InvalidTenantAccess) { @bezos.save(validate: false) }

      @bezos.reload
      assert_equal "Jeff Bezos", @bezos.name
    end
  end

  ####
  # .write_attribute + .save
  ####
  test "raise error on update through .write_attribute + .save when user.account not matching current tenant" do
    @bezos.write_attribute(:name, "JUFF BEZOS")
    MultiTenantSupport.under_tenant accounts(:facebook) do
      assert_raise(MultiTenantSupport::InvalidTenantAccess) { @bezos.save }
    end

    MultiTenantSupport.under_tenant accounts(:amazon) do
      @bezos.reload
      assert_equal "Jeff Bezos", @bezos.name
    end
  end

  ####
  # .update
  ####
  test "raise error on update through update when user.account not matching current tenant" do
    MultiTenantSupport.under_tenant accounts(:facebook) do
      assert_raise(MultiTenantSupport::InvalidTenantAccess) { @bezos.update(name: 'JUFF BEZOS') }
    end

    MultiTenantSupport.under_tenant accounts(:amazon) do
      @bezos.reload
      assert_equal "Jeff Bezos", @bezos.name
    end
  end

  test "raise error on update through update when missing current tenant and allow read across tenant" do
    MultiTenantSupport.allow_read_across_tenant do
      assert_raise(MultiTenantSupport::InvalidTenantAccess) { @bezos.update(name: 'JUFF BEZOS') }

      @bezos.reload
      assert_equal "Jeff Bezos", @bezos.name
    end
  end

  ####
  # .update_attribute
  ####
  test "raise error on update through update_attribute when user.account not matching current tenant" do
    MultiTenantSupport.under_tenant accounts(:facebook) do
      assert_raise(MultiTenantSupport::InvalidTenantAccess) { @bezos.update_attribute(:name, 'JUFF BEZOS') }
    end

    MultiTenantSupport.under_tenant accounts(:amazon) do
      @bezos.reload
      assert_equal "Jeff Bezos", @bezos.name
    end
  end

  test "raise error on update through update_attribute when missing current tenant and allow read across tenant" do
    MultiTenantSupport.allow_read_across_tenant do
      assert_raise(MultiTenantSupport::InvalidTenantAccess) { @bezos.update_attribute(:name, 'JUFF BEZOS') }

      @bezos.reload
      assert_equal "Jeff Bezos", @bezos.name
    end
  end

  ####
  # .update_columns
  ####
  test "raise error on update through update_columns when user.account not matching current tenant" do
    MultiTenantSupport.under_tenant accounts(:facebook) do
      assert_raise(MultiTenantSupport::InvalidTenantAccess) { @bezos.update_columns(name: 'JUFF BEZOS') }
    end

    MultiTenantSupport.under_tenant accounts(:amazon) do
      @bezos.reload
      assert_equal "Jeff Bezos", @bezos.name
    end
  end

  test "raise error on update through update_columns when missing current tenant and allow read across tenant" do
    MultiTenantSupport.allow_read_across_tenant do
      assert_raise(MultiTenantSupport::InvalidTenantAccess) { @bezos.update_columns(name: 'JUFF BEZOS') }

      @bezos.reload
      assert_equal "Jeff Bezos", @bezos.name
    end
  end

  ####
  # .update_column
  ####
  test "raise error on update through update_column when user.account not matching current tenant" do
    MultiTenantSupport.under_tenant accounts(:facebook) do
      assert_raise(MultiTenantSupport::InvalidTenantAccess) { @bezos.update_column(:name, 'JUFF BEZOS') }
    end

    MultiTenantSupport.under_tenant accounts(:amazon) do
      @bezos.reload
      assert_equal "Jeff Bezos", @bezos.name
    end
  end

  test "raise error on update through update_column when missing current tenant and allow read across tenant" do
    MultiTenantSupport.allow_read_across_tenant do
      assert_raise(MultiTenantSupport::InvalidTenantAccess) { @bezos.update_column(:name, 'JUFF BEZOS') }

      @bezos.reload
      assert_equal "Jeff Bezos", @bezos.name
    end
  end

  ####
  # .upsert_all
  ####
  test ".upsert_all - won't succes when disallow read across tenant and tenant is missing" do
    MultiTenantSupport.allow_read_across_tenant do
      assert_equal 3, User.count
    end

    out, err = capture_io do
      assert_raise MultiTenantSupport::MissingTenantError do
        User.upsert_all([
          {name: 'JUFF BEZOS', email: 'bezos@example.com', created_at: Time.current, updated_at: Time.current},
          {name: 'MARK ZUCKERBERG', email: 'zuck@example.com', created_at: Time.current, updated_at: Time.current},
          {name: 'New User', email: 'new.user@example.com', created_at: Time.current, updated_at: Time.current}
        ], unique_by: :email)
      end
    end

    assert_equal "[WARNING] You are using upsert_all(or upsert) which may update records across tenants\n", err

    MultiTenantSupport.allow_read_across_tenant do
      assert_equal 3, User.count
    end
  end

  test ".upsert_all - will warn user on call this method when allow read across tenant and tenant is missing" do
    MultiTenantSupport.allow_read_across_tenant do
      assert_difference 'User.count', 1 do
        out, err = capture_io do
          User.upsert_all([
            {name: 'JUFF BEZOS', email: 'bezos@example.com', created_at: Time.current, updated_at: Time.current},
            {name: 'MARK ZUCKERBERG', email: 'zuck@example.com', created_at: Time.current, updated_at: Time.current},
            {name: 'New User', email: 'new.user@example.com', created_at: Time.current, updated_at: Time.current}
          ], unique_by: :email)
        end

        assert_equal "[WARNING] You are using upsert_all(or upsert) which may update records across tenants\n", err
        assert User.find_by(email: 'new.user@example.com').account_id.nil?
        assert_equal 'JUFF BEZOS', User.find_by(email: 'bezos@example.com').name
        assert_equal 'MARK ZUCKERBERG', User.find_by(email: 'zuck@example.com').name
      end
    end
  end

  test ".upsert_all - will warn user on call this method when disallow read across tenant and tenant exist" do
    MultiTenantSupport.under_tenant(accounts(:apple)) do
      assert_difference 'User.count', 1 do
        out, err = capture_io do
          User.upsert_all([
            {name: 'JUFF BEZOS', email: 'bezos@example.com', created_at: Time.current, updated_at: Time.current},
            {name: 'MARK ZUCKERBERG', email: 'zuck@example.com', created_at: Time.current, updated_at: Time.current},
            {name: 'New User', email: 'new.user@example.com', created_at: Time.current, updated_at: Time.current}
          ], unique_by: :email)
        end

        assert_equal "[WARNING] You are using upsert_all(or upsert) which may update records across tenants\n", err
        assert_equal accounts(:apple), User.find_by(email: 'new.user@example.com').account
        assert_equal 2, User.count
      end
    end
  end

  test ".upsert_all - will warn user on call this method when allow read across tenant and tenant exist" do
    MultiTenantSupport.allow_read_across_tenant do
      MultiTenantSupport.under_tenant(accounts(:apple)) do
        assert_difference 'User.count', 1 do
          out, err = capture_io do
            User.upsert_all([
              {name: 'JUFF BEZOS', email: 'bezos@example.com', created_at: Time.current, updated_at: Time.current},
              {name: 'MARK ZUCKERBERG', email: 'zuck@example.com', created_at: Time.current, updated_at: Time.current},
              {name: 'New User', email: 'new.user@example.com', created_at: Time.current, updated_at: Time.current}
            ], unique_by: :email)
          end

          assert_equal "[WARNING] You are using upsert_all(or upsert) which may update records across tenants\n", err
          assert_equal accounts(:apple), User.find_by(email: 'new.user@example.com').account
          assert_equal 2, User.count
        end
      end
    end
  end

  ####
  # .upsert
  ####
  test ".upsert - won't succes when disallow read across tenant and tenant is missing" do
    MultiTenantSupport.allow_read_across_tenant do
      assert_equal 3, User.count
    end

    out, err = capture_io do
      assert_raise MultiTenantSupport::MissingTenantError do
        User.upsert({name: 'JUFF BEZOS', email: 'bezos@example.com', created_at: Time.current, updated_at: Time.current}, unique_by: :email)
        User.upsert({name: 'MARK ZUCKERBERG', email: 'zuck@example.com', created_at: Time.current, updated_at: Time.current}, unique_by: :email)
        User.upsert({name: 'New User', email: 'new.user@example.com', created_at: Time.current, updated_at: Time.current}, unique_by: :email)
      end
    end

    assert_equal "[WARNING] You are using upsert_all(or upsert) which may update records across tenants\n", err

    MultiTenantSupport.allow_read_across_tenant do
      assert_equal 3, User.count
    end
  end

  test ".upsert - will warn user on call this method when allow read across tenant and tenant is missing" do
    MultiTenantSupport.allow_read_across_tenant do
      assert_difference 'User.count', 1 do
        out, err = capture_io do
          User.upsert({name: 'JUFF BEZOS', email: 'bezos@example.com', created_at: Time.current, updated_at: Time.current}, unique_by: :email)
          User.upsert({name: 'MARK ZUCKERBERG', email: 'zuck@example.com', created_at: Time.current, updated_at: Time.current}, unique_by: :email)
          User.upsert({name: 'New User', email: 'new.user@example.com', created_at: Time.current, updated_at: Time.current}, unique_by: :email)
        end

        assert_includes err, "[WARNING] You are using upsert_all(or upsert) which may update records across tenants\n"
        assert User.find_by(email: 'new.user@example.com').account_id.nil?
        assert_equal 'JUFF BEZOS', User.find_by(email: 'bezos@example.com').name
        assert_equal 'MARK ZUCKERBERG', User.find_by(email: 'zuck@example.com').name
      end
    end
  end

  test ".upsert - will warn user on call this method when disallow read across tenant and tenant exist" do
    MultiTenantSupport.under_tenant(accounts(:apple)) do
      assert_difference 'User.count', 1 do
        out, err = capture_io do
          User.upsert({name: 'JUFF BEZOS', email: 'bezos@example.com', created_at: Time.current, updated_at: Time.current}, unique_by: :email)
          User.upsert({name: 'MARK ZUCKERBERG', email: 'zuck@example.com', created_at: Time.current, updated_at: Time.current}, unique_by: :email)
          User.upsert({name: 'New User', email: 'new.user@example.com', created_at: Time.current, updated_at: Time.current}, unique_by: :email)
        end

        assert_includes err, "[WARNING] You are using upsert_all(or upsert) which may update records across tenants\n"
        assert_equal accounts(:apple), User.find_by(email: 'new.user@example.com').account
        assert_equal 2, User.count
      end
    end
  end

  test ".upsert - will warn user on call this method when allow read across tenant and tenant exist" do
    MultiTenantSupport.allow_read_across_tenant do
      MultiTenantSupport.under_tenant(accounts(:apple)) do
        assert_difference 'User.count', 1 do
          out, err = capture_io do
            User.upsert({name: 'JUFF BEZOS', email: 'bezos@example.com', created_at: Time.current, updated_at: Time.current}, unique_by: :email)
            User.upsert({name: 'MARK ZUCKERBERG', email: 'zuck@example.com', created_at: Time.current, updated_at: Time.current}, unique_by: :email)
            User.upsert({name: 'New User', email: 'new.user@example.com', created_at: Time.current, updated_at: Time.current}, unique_by: :email)
          end

          assert_includes err, "[WARNING] You are using upsert_all(or upsert) which may update records across tenants\n"
          assert_equal accounts(:apple), User.find_by(email: 'new.user@example.com').account
          assert_equal 2, User.count
        end
      end
    end
  end

  ####
  # .update_all
  ####
  test ".update_all - won't succes when tenant is missing" do
    assert_raise MultiTenantSupport::MissingTenantError do
      User.update_all(name: 'NAME')
    end

    MultiTenantSupport.allow_read_across_tenant do
      refute User.pluck(:name).include?('NAME')
    end

    MultiTenantSupport.allow_read_across_tenant do
      assert_raise MultiTenantSupport::MissingTenantError do
        User.update_all(name: 'NAME')
      end
    end

    MultiTenantSupport.allow_read_across_tenant do
      refute User.pluck(:name).include?('NAME')
    end
  end

  test ".update_all - can success update when tenant exist" do
    MultiTenantSupport.under_tenant accounts(:apple) do
      User.update_all(name: 'NAME')
    end

    MultiTenantSupport.allow_read_across_tenant do
      assert_equal 3, User.count
      assert_equal 1, User.where(name: 'NAME').count
    end
  end

end
