require 'test_helper'

class MultiTenantSupport::ModelConcern::BelongsToTenant_UpdateTest < ActiveSupport::TestCase

  setup do
    MultiTenantSupport.under_tenant accounts(:amazon) do
      @bezos = users(:bezos)
    end
  end

  ####
  # .upsert_all
  ####
  test ".upsert_all - won't succes when disallow read across tenant and tenant is missing" do
    MultiTenantSupport.allow_read_across_tenant do
      assert_equal 3, User.count
    end

    _, err = capture_io do
      assert_raise MultiTenantSupport::MissingTenantError do
        User.upsert_all([
          {name: 'JEFF BEZOS', email: 'bezos@example.com', created_at: Time.current, updated_at: Time.current},
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
        _, err = capture_io do
          User.upsert_all([
            {name: 'JEFF BEZOS', email: 'bezos@example.com', created_at: Time.current, updated_at: Time.current},
            {name: 'MARK ZUCKERBERG', email: 'zuck@example.com', created_at: Time.current, updated_at: Time.current},
            {name: 'New User', email: 'new.user@example.com', created_at: Time.current, updated_at: Time.current}
          ], unique_by: :email)
        end

        assert_equal "[WARNING] You are using upsert_all(or upsert) which may update records across tenants\n", err
        assert User.find_by(email: 'new.user@example.com').account_id.nil?
        assert_equal 'JEFF BEZOS', User.find_by(email: 'bezos@example.com').name
        assert_equal 'MARK ZUCKERBERG', User.find_by(email: 'zuck@example.com').name
      end
    end
  end

  test ".upsert_all - will warn user on call this method when disallow read across tenant and tenant exist" do
    MultiTenantSupport.under_tenant(accounts(:apple)) do
      assert_difference 'User.count', 1 do
        _, err = capture_io do
          User.upsert_all([
            {name: 'JEFF BEZOS', email: 'bezos@example.com', created_at: Time.current, updated_at: Time.current},
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
          _, err = capture_io do
            User.upsert_all([
              {name: 'JEFF BEZOS', email: 'bezos@example.com', created_at: Time.current, updated_at: Time.current},
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

    _, err = capture_io do
      assert_raise MultiTenantSupport::MissingTenantError do
        User.upsert({name: 'JEFF BEZOS', email: 'bezos@example.com', created_at: Time.current, updated_at: Time.current}, unique_by: :email)
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
        _, err = capture_io do
          User.upsert({name: 'JEFF BEZOS', email: 'bezos@example.com', created_at: Time.current, updated_at: Time.current}, unique_by: :email)
          User.upsert({name: 'MARK ZUCKERBERG', email: 'zuck@example.com', created_at: Time.current, updated_at: Time.current}, unique_by: :email)
          User.upsert({name: 'New User', email: 'new.user@example.com', created_at: Time.current, updated_at: Time.current}, unique_by: :email)
        end

        assert_includes err, "[WARNING] You are using upsert_all(or upsert) which may update records across tenants\n"
        assert User.find_by(email: 'new.user@example.com').account_id.nil?
        assert_equal 'JEFF BEZOS', User.find_by(email: 'bezos@example.com').name
        assert_equal 'MARK ZUCKERBERG', User.find_by(email: 'zuck@example.com').name
      end
    end
  end

  test ".upsert - will warn user on call this method when disallow read across tenant and tenant exist" do
    MultiTenantSupport.under_tenant(accounts(:apple)) do
      assert_difference 'User.count', 1 do
        _, err = capture_io do
          User.upsert({name: 'JEFF BEZOS', email: 'bezos@example.com', created_at: Time.current, updated_at: Time.current}, unique_by: :email)
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
          _, err = capture_io do
            User.upsert({name: 'JEFF BEZOS', email: 'bezos@example.com', created_at: Time.current, updated_at: Time.current}, unique_by: :email)
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
