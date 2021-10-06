require "test_helper"

class CustomizeCurrentTenantFinderTest < ActionDispatch::IntegrationTest

  setup do
    @amazon = accounts(:amazon)
  end

  test "find correct tenant with subdomain" do
    host! "amazon.example.com"
    get user_tags_path

    assert_redirected_to super_admin_dashboard_path
    follow_redirect!
    assert_response :success
    assert_select "h1", text: "SuperAdmin Dashboard"
  end

  test "find correct tenant with domain" do
    host! "amazon.com"
    get user_tags_path

    assert_response :success
    assert_select "#id", text: @amazon.id.to_s
    assert_select "#name", text: "Amazon"
    assert_select "#domain", text: "amazon.com"
    assert_select "#subdomain", text: "amazon"
  end

  test "can't find tenant when visit the host domain" do
    host! "example.com"
    get user_tags_path

    assert_redirected_to super_admin_dashboard_path
    follow_redirect!
    assert_response :success
    assert_select "h1", text: "SuperAdmin Dashboard"
  end

end
