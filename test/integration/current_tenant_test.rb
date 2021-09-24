require "test_helper"

class CurrentTenantTest < ActionDispatch::IntegrationTest

  setup do
    @william = accounts(:william)
  end

  test "find correct tenant with subdomain (i.e. subdomain.example.com)" do
    host! "william.example.com"
    get users_path

    assert_response :success
    assert_select "#id", text: @william.id.to_s
    assert_select "#name", text: "WILLIAM"
    assert_select "#domain", text: "william.com"
    assert_select "#subdomain", text: "william"
  end

  test "find correct tenant with domain (i.e. william.com)" do
    host! "william.com"
    get users_path

    assert_response :success
    assert_select "#id", text: @william.id.to_s
    assert_select "#name", text: "WILLIAM"
    assert_select "#domain", text: "william.com"
    assert_select "#subdomain", text: "william"
  end

end
