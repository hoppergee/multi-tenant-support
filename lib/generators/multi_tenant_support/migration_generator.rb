require "rails/generators/active_record"

module MultiTenantSupport
  module Generators
    class MigrationGenerator < Rails::Generators::NamedBase
      include ActiveRecord::Generators::Migration
      source_root File.expand_path('templates', __dir__)

      desc "Create a migration for multi-tenant-support"

      def copy_migration_file
        migration_template "migration.rb.tt", "db/migrate/add_domain_and_subdomain_to_#{table_name}.rb"
        puts "\nPlease run this migration:\n\n    rails db:migrate"
      end

      def migration_version
        "[#{ActiveRecord::VERSION::MAJOR}.#{ActiveRecord::VERSION::MINOR}]"
      end
    end
  end
end
