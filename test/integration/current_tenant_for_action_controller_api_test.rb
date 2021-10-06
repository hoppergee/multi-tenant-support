require 'test_helper'

class CurrentTenantForActionControllerApiTest < ActionDispatch::IntegrationTest

  setup do
    @amazon = accounts(:amazon)
  end

  test "find correct tenant with subdomain" do
    host! "amazon.example.com"
    get api_users_path

    assert_response :success
    assert_json_response({
      "tenant"=>"Amazon",
      "domain"=>"amazon.com",
      "subdomain"=>"amazon"
    })
  end

  test "find correct tenant with domain" do
    host! "amazon.com"
    get api_users_path

    assert_response :success
    assert_json_response({
      "tenant"=>"Amazon",
      "domain"=>"amazon.com",
      "subdomain"=>"amazon"
    })
  end

  test "can't find tenant when visit the host domain" do
    host! "example.com"
    get api_users_path

    assert_response :success
    assert_json_response({
      "error" => "Wrong domain or subdomain"
    })
  end

  def assert_json_response(hash)
    body = JSON.parse(response.body)

    assert_kind_of Hash, body
    assert_equal hash.count, body.count
    hash.each do |key, expected|
      assert_equal expected, body[key]
    end
  end

end