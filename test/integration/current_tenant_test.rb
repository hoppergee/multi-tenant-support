require "test_helper"

class CurrentTenantTest < ActionDispatch::IntegrationTest

  setup do
    @beer_stark = accounts(:beer_stark)
  end

  test "find correct tenant with subdomain" do
    host! "beerstark.example.com"
    get users_path

    assert_response :success
    assert_select "#id", text: @beer_stark.id.to_s
    assert_select "#name", text: "BeerStark"
    assert_select "#domain", text: "beer-stark.com"
    assert_select "#subdomain", text: "beerstark"
  end

  test "find correct tenant with domain" do
    host! "beer-stark.com"
    get users_path

    assert_response :success
    assert_select "#id", text: @beer_stark.id.to_s
    assert_select "#name", text: "BeerStark"
    assert_select "#domain", text: "beer-stark.com"
    assert_select "#subdomain", text: "beerstark"
  end

end
