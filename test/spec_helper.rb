# Configure Rails Environment
ENV["RAILS_ENV"] = "test"

require_relative "../test/dummy/config/environment"
ActiveRecord::Migrator.migrations_paths = [File.expand_path("../test/dummy/db/migrate", __dir__)]
ActiveRecord::Migration.maintain_test_schema!

require "rspec/rails"
require 'multi_tenant_support/rspec'

RSpec.configure do |config|
  config.fixture_path = "test/fixtures"
  config.global_fixtures = :all
  config.use_transactional_fixtures = true
end

