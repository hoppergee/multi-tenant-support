require "test_helper"

class MultiTenantSupport::Config::ConsoleTest < ActiveSupport::TestCase

  setup do
    @console_config = MultiTenantSupport::Config::Console.new
  end

  test "#allow_read_across_tenant_by_default and #allow_read_across_tenant_by_default=" do
    assert_equal false, @console_config.allow_read_across_tenant_by_default

    @console_config.allow_read_across_tenant_by_default = true
    assert_equal true, @console_config.allow_read_across_tenant_by_default

    @console_config.allow_read_across_tenant_by_default = false
    assert_equal false, @console_config.allow_read_across_tenant_by_default
  end

end