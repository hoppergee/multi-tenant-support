require "test_helper"

class CurrentTenantTest < ActionDispatch::IntegrationTest

  setup do
    @amazon = accounts(:amazon)
  end

  test "find correct tenant with subdomain" do
    host! "amazon.example.com"
    get users_path

    assert_response :success
    assert_select "#id", text: @amazon.id.to_s
    assert_select "#name", text: "Amazon"
    assert_select "#domain", text: "amazon.com"
    assert_select "#subdomain", text: "amazon"
  end

  test "find correct tenant with domain" do
    host! "amazon.com"
    get users_path

    assert_response :success
    assert_select "#id", text: @amazon.id.to_s
    assert_select "#name", text: "Amazon"
    assert_select "#domain", text: "amazon.com"
    assert_select "#subdomain", text: "amazon"
  end

end
