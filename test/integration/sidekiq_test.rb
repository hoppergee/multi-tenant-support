require 'test_helper'
require 'sidekiq'
require 'sidekiq/testing'
require 'multi_tenant_support/sidekiq'

class SidekiqIntegrationTest < ActiveSupport::TestCase

  class UserNameUpdateWorker
    include Sidekiq::Worker
    def perform(user_id)
      user = User.find(user_id)
      user.update(name: user.name + " UPDATE")
    end
  end

  setup do
    Sidekiq::Testing.server_middleware do |chain|
      chain.add MultiTenantSupport::Sidekiq::Server
    end

    Sidekiq::Testing.fake!
    UserNameUpdateWorker.jobs.clear


    MultiTenantSupport.under_tenant(accounts(:amazon)) do
      @bezos = users(:bezos)
    end
  end

  teardown do
    UserNameUpdateWorker.clear
    Sidekiq::Testing.disable!
    Sidekiq::Queues.clear_all
  end

  test "successfully update user name when tenant_account is correct" do
    MultiTenantSupport.under_tenant(accounts(:amazon)) do
      UserNameUpdateWorker.perform_async(@bezos.id)
    end

    UserNameUpdateWorker.perform_one

    MultiTenantSupport.under_tenant(accounts(:amazon)) do
      assert_equal "Jeff Bezos UPDATE", @bezos.reload.name
    end
  end

  test "raise error when tenant_account does not matach" do
    MultiTenantSupport.under_tenant(accounts(:apple)) do
      UserNameUpdateWorker.perform_async(@bezos.id)
    end

    assert_raise ActiveRecord::RecordNotFound do
      UserNameUpdateWorker.perform_one
    end

    MultiTenantSupport.under_tenant(accounts(:amazon)) do
      refute_equal "Jeff Bezos UPDATE", @bezos.reload.name
    end
  end

  test "raise error when tenant_account is missing" do
    UserNameUpdateWorker.perform_async(@bezos.id)

    assert_raise MultiTenantSupport::MissingTenantError do
      UserNameUpdateWorker.perform_one
    end

    MultiTenantSupport.under_tenant(accounts(:amazon)) do
      refute_equal "Jeff Bezos UPDATE", @bezos.reload.name
    end
  end

end
