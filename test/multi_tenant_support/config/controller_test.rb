require "test_helper"

class MultiTenantSupport::Config::ControllerTest < ActiveSupport::TestCase

  setup do
    @controller_config = MultiTenantSupport::Config::Controller.new
  end

  test "#current_tenant_account_method and #current_tenant_account_method=" do
    assert_equal :current_tenant_account, @controller_config.current_tenant_account_method

    @controller_config.current_tenant_account_method = :current_account
    assert_equal :current_account, @controller_config.current_tenant_account_method
  end

end