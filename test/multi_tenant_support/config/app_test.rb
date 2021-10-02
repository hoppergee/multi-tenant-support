require "test_helper"

class MultiTenantSupport::Config::AppTest < ActiveSupport::TestCase

  setup do
    @app_config = MultiTenantSupport::Config::App.new
  end

  test "#excluded_subdomains and #excluded_subdomains=" do
    assert_equal [], @app_config.excluded_subdomains

    @app_config.excluded_subdomains = ["www"]
    assert_equal ["www"], @app_config.excluded_subdomains
  end

  test "#host and #host=" do
    assert_raise "host is missing" do
      @app_config.host
    end

    @app_config.host = "example.com"
    assert_equal "example.com", @app_config.host
  end

end