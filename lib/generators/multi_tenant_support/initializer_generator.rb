require "rails/generators"

module MultiTenantSupport
  module Generators
    class InitializerGenerator < Rails::Generators::Base
      source_root File.expand_path('templates', __dir__)

      desc "Create an initializer for multi-tenant-support"

      def copy_initializer_file
        copy_file "initializer.rb.tt", "config/initializers/multi_tenant_support.rb"
      end
    end
  end
end
