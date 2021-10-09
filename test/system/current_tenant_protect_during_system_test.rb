require 'test_helper'

class CurrentTenantProtectDuringSystemTeste < ActionDispatch::SystemTestCase
  driven_by :rack_test

  setup do
    Capybara.app_host = "http://amazon.example.com"
    MultiTenantSupport::Current.tenant_account = accounts(:amazon)
  end

  test "curren tenant won't reset by visit" do
    assert_equal accounts(:amazon), MultiTenantSupport.current_tenant

    assert_no_changes 'MultiTenantSupport.current_tenant' do
      visit users_path
    end

    assert_content "Users#index"
    assert_selector "#id", text: amazon.id.to_s
    assert_selector "#name", text: "Amazon"
    assert_selector "#domain", text: "amazon.com"
    assert_selector "#subdomain", text: "amazon"
  end

  test "curren tenant won't reset by refresh" do
    visit users_path

    assert_equal accounts(:amazon), MultiTenantSupport.current_tenant
    assert_no_changes 'MultiTenantSupport.current_tenant' do
      refresh
    end
  end

  test "curren tenant won't reset by click_on" do
    visit users_path

    assert_equal accounts(:amazon), MultiTenantSupport.current_tenant
    assert_no_changes 'MultiTenantSupport.current_tenant' do
      click_on "Show"
      assert_content "User - Show"
    end
  end

  test "curren tenant won't reset by click" do
    visit users_path

    assert_equal accounts(:amazon), MultiTenantSupport.current_tenant
    assert_no_changes 'MultiTenantSupport.current_tenant' do
      find_link("Show").click
      assert_content "User - Show"
    end
  end

end