require 'test_helper'
require 'sidekiq'
require 'multi_tenant_support/sidekiq'

class MultiTenantSupport::SidekiqTest < ActiveSupport::TestCase

  test "Client success set current tenant id to msg" do
    msg = {}
    MultiTenantSupport::Sidekiq::Client.new.call(nil, msg, nil, nil) {}
    assert msg["multi_tenant_support"].nil?

    MultiTenantSupport.under_tenant accounts(:amazon) do
      msg = {}
      MultiTenantSupport::Sidekiq::Client.new.call(nil, msg, nil, nil) {}
      assert "Account", msg["multi_tenant_support"]["class"]
      assert accounts(:amazon).id, msg["multi_tenant_support"]["id"]
    end
  end

  test "Server success set current tenant if need" do
    msg = {}
    MultiTenantSupport::Sidekiq::Server.new.call(nil, msg, nil) {}
    assert MultiTenantSupport.current_tenant.nil?

    msg = {
      "multi_tenant_support" => {
        "class" => "Account",
        "id" => accounts(:amazon).id
      }
    }
    current_tenant = nil
    MultiTenantSupport::Sidekiq::Server.new.call(nil, msg, nil) do
      current_tenant = MultiTenantSupport.current_tenant
    end
    assert_equal accounts(:amazon), current_tenant
  end
end
