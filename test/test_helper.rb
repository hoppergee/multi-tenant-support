# Configure Rails Environment
ENV["RAILS_ENV"] = "test"
require "minitest/autorun"
require "minitest/focus"

require_relative "../test/dummy/config/environment"
ActiveRecord::Migrator.migrations_paths = [File.expand_path("../test/dummy/db/migrate", __dir__)]
require "rails/test_help"

ActiveRecord::Migration.maintain_test_schema!

require "rails/test_unit/reporter"
Rails::TestUnitReporter.executable = 'bin/test'

# Load fixtures from the engine
if ActiveSupport::TestCase.respond_to?(:fixture_path=)
  ActiveSupport::TestCase.fixture_path = File.expand_path("fixtures", __dir__)
  ActionDispatch::IntegrationTest.fixture_path = ActiveSupport::TestCase.fixture_path
  ActiveSupport::TestCase.file_fixture_path = ActiveSupport::TestCase.fixture_path + "/files"
  ActiveSupport::TestCase.fixtures :all
end

require 'support/dsl'

class ActiveSupport::TestCase
  include MultiTenantSupport::DSL

  self.use_transactional_tests = false

  setup { setup_users }
end

require 'support/sidekiq_jobs_manager'
require 'multi_tenant_support/active_job'
SidekiqJobsManager.instance.start_workers

Minitest.after_run do
  SidekiqJobsManager.instance.stop_workers
  SidekiqJobsManager.instance.clear_jobs

  ActiveRecord::Tasks::DatabaseTasks.truncate_all(
    ActiveSupport::StringInquirer.new("test")
  )
end

require 'multi_tenant_support/minitest'