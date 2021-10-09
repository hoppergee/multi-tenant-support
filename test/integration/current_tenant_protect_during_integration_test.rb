require 'test_helper'

class CurrentTenantProtectDuringIntegrationTeste < ActionDispatch::IntegrationTest

  setup do
    host! "amazon.example.com"
    MultiTenantSupport::Current.tenant_account = accounts(:amazon)
  end

  test "curren tenant won't reset by get" do
    assert_equal accounts(:amazon), MultiTenantSupport.current_tenant
    get users_path
    assert_response :success
    assert_equal accounts(:amazon), MultiTenantSupport.current_tenant
  end

  test "curren tenant won't reset by post" do
    assert_equal accounts(:amazon), MultiTenantSupport.current_tenant
    post users_path
    assert_redirected_to users_path
    assert_equal accounts(:amazon), MultiTenantSupport.current_tenant
  end

  test "curren tenant won't reset by patch" do
    assert_equal accounts(:amazon), MultiTenantSupport.current_tenant
    patch user_path(id: 1)
    assert_redirected_to users_path
    assert_equal accounts(:amazon), MultiTenantSupport.current_tenant
  end

  test "curren tenant won't reset by put" do
    assert_equal accounts(:amazon), MultiTenantSupport.current_tenant
    put user_path(id: 1)
    assert_equal accounts(:amazon), MultiTenantSupport.current_tenant
  end

  test "curren tenant won't reset by delete" do
    assert_equal accounts(:amazon), MultiTenantSupport.current_tenant
    delete user_path(id: 1)
    assert_equal accounts(:amazon), MultiTenantSupport.current_tenant
  end

end