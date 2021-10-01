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
    setup_sidekiq_middlewares

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

    remove_sidekiq_middlewares
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

  def setup_sidekiq_middlewares
    Sidekiq::Testing.server_middleware do |chain|
      chain.add MultiTenantSupport::Sidekiq::Server
    end

    Sidekiq.configure_client do |config|
      config.client_middleware do |chain|
        chain.add MultiTenantSupport::Sidekiq::Client
      end
    end

    Sidekiq.configure_server do |config|
      config.client_middleware do |chain|
        chain.add MultiTenantSupport::Sidekiq::Client
      end

      config.server_middleware do |chain|
        if defined?(Sidekiq::Middleware::Server::RetryJobs)
          chain.insert_before Sidekiq::Middleware::Server::RetryJobs, MultiTenantSupport::Sidekiq::Server
        elsif defined?(Sidekiq::Batch::Server)
          chain.insert_before Sidekiq::Batch::Server, MultiTenantSupport::Sidekiq::Server
        else
          chain.add MultiTenantSupport::Sidekiq::Server
        end
      end
    end
  end

  def remove_sidekiq_middlewares
    Sidekiq::Testing.server_middleware do |chain|
      chain.remove MultiTenantSupport::Sidekiq::Server
    end

    Sidekiq.configure_client do |config|
      config.client_middleware do |chain|
        chain.remove MultiTenantSupport::Sidekiq::Client
      end
    end

    Sidekiq.configure_server do |config|
      config.client_middleware do |chain|
        chain.remove MultiTenantSupport::Sidekiq::Client
      end
      config.server_middleware do |chain|
        chain.remove MultiTenantSupport::Sidekiq::Server
      end
    end
  end

end
