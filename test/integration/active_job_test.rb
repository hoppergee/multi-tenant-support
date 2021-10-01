require 'test_helper'
require 'sidekiq'
require 'sidekiq/testing'
require 'support/sidekiq_jobs_manager'
require 'multi_tenant_support/active_job'

class ActiveJobIntegrationTest < ActiveSupport::TestCase

  class UserNameUpdateJob < ApplicationJob
    queue_as :integration_tests

    def perform(user)
      user.update(name: user.name + " UPDATE")
    end
  end

  setup do
    MultiTenantSupport.under_tenant(accounts(:amazon)) do
      @bezos = users(:bezos)
    end

    SidekiqJobsManager.instance.start_workers
  end

  teardown do
    SidekiqJobsManager.instance.stop_workers
    SidekiqJobsManager.instance.clear_jobs
  end

  test 'update succes update user when tenant account match' do
    MultiTenantSupport.under_tenant(accounts(:amazon)) do
      UserNameUpdateJob.perform_later(@bezos)
    end

    sleep 1

    MultiTenantSupport.under_tenant(accounts(:amazon)) do
      assert_equal "Jeff Bezos UPDATE", @bezos.reload.name
    end
  end

  test 'fail to update user when tenant account is missing on enqueue' do
    UserNameUpdateJob.perform_later(@bezos)

    sleep 1

    Sidekiq.redis do |connection|
      retries = connection.zrange "retry", 0, -1
      assert 1, retries.count
      failed_job_data = JSON.parse(retries.first)
      assert_equal "Error while trying to deserialize arguments: MultiTenantSupport::MissingTenantError", failed_job_data["error_message"]
      assert_equal "ActiveJob::DeserializationError", failed_job_data["error_class"]
    end

    MultiTenantSupport.under_tenant(accounts(:amazon)) do
      assert_equal "Jeff Bezos", @bezos.reload.name # Does not change
    end
  end

  test 'fail to update user when tenant account is not match' do
    MultiTenantSupport.under_tenant(accounts(:apple)) do
      UserNameUpdateJob.perform_later(@bezos)
    end

    sleep 1

    Sidekiq.redis do |connection|
      retries = connection.zrange "retry", 0, -1
      assert 1, retries.count
      failed_job_data = JSON.parse(retries.first)
      assert_equal "Error while trying to deserialize arguments: MultiTenantSupport::MissingTenantError", failed_job_data["error_message"]
      assert_equal "ActiveJob::DeserializationError", failed_job_data["error_class"]
    end

    MultiTenantSupport.under_tenant(accounts(:amazon)) do
      assert_equal "Jeff Bezos", @bezos.reload.name # Does not change
    end
  end

end
