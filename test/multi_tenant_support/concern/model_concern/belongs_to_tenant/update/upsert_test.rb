require 'test_helper'

class ModelUpsertProtectTest < ActiveSupport::TestCase

  ####
  # .upsert
  ####
  test "will not protect upsert when call under the tenant" do
    within_a_request_of amazon do
      assert_not_protect_upsert with_warn: "[WARNING] You are using upsert_all(or upsert) which may update records across tenants\n"
    end
  end

  test "fail to upsert when tenant is missing" do
    turn_on_full_protection do
      missing_tenant do
        refute_upsert MultiTenantSupport::MissingTenantError, with_warn: "[WARNING] You are using upsert_all(or upsert) which may update records across tenants\n"
      end
    end
  end

  test 'will not protect upsert when call by super admin' do
    within_a_request_of super_admin do
      assert_not_protect_upsert with_warn: "[WARNING] You are using upsert_all(or upsert) which may update records across tenants\n"
    end
  end

  test 'will not protect upsert when call by super admin even manual set current tenant' do
    within_a_request_of super_admin do
      under_tenant amazon do
        assert_not_protect_upsert with_warn: "[WARNING] You are using upsert_all(or upsert) which may update records across tenants\n"
      end
    end
  end

  test 'will not get warn on call upsert when turn off protection' do
    within_a_request_of super_admin do
      turn_off_protection do
        assert_not_protect_upsert with_warn: nil
      end
    end
  end

  private

  def assert_not_protect_upsert(with_warn:)
    as_super_admin do
      assert_equal 3, User.unscope_tenant.count
    end

    _, warn_message = capture_io do
      User.upsert({name: 'JEFF BEZOS', email: 'bezos@example.com', created_at: Time.current, updated_at: Time.current}, unique_by: :email)
      User.upsert({name: 'MARK ZUCKERBERG', email: 'zuck@example.com', created_at: Time.current, updated_at: Time.current}, unique_by: :email)
      User.upsert({name: 'New User', email: 'new.user@example.com', created_at: Time.current, updated_at: Time.current}, unique_by: :email)
    end

    if with_warn
      assert_includes warn_message, with_warn
    else
      assert_no_match /WARNING/, warn_message
    end

    as_super_admin do
      without_current_tenant do
        assert_equal 4, User.unscope_tenant.count
        assert_equal 'JEFF BEZOS', bezos.reload.name
        assert_equal 'MARK ZUCKERBERG', zuck.reload.name
        assert_equal 'New User', User.find_by(email: 'new.user@example.com').name
      end
    end
  end

  def refute_upsert(error, with_warn:)
    as_super_admin do
      assert_equal 3, User.unscope_tenant.count
    end

    _, warn_message = capture_io do
      assert_raise error do
        User.upsert({name: 'JEFF BEZOS', email: 'bezos@example.com', created_at: Time.current, updated_at: Time.current}, unique_by: :email)
        User.upsert({name: 'MARK ZUCKERBERG', email: 'zuck@example.com', created_at: Time.current, updated_at: Time.current}, unique_by: :email)
        User.upsert({name: 'New User', email: 'new.user@example.com', created_at: Time.current, updated_at: Time.current}, unique_by: :email)
      end
    end

    assert_includes warn_message, with_warn

    as_super_admin do
      without_current_tenant do
        assert_equal 3, User.unscope_tenant.count
        assert_equal 'Jeff Bezos', bezos.reload.name
        assert_equal 'Mark Zuckerberg', zuck.reload.name
      end
    end
  end

end
