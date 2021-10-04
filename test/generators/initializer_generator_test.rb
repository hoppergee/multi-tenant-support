require "test_helper"
require "generators/multi_tenant_support/initializer_generator"

class InitializerGeneratorTest < Rails::Generators::TestCase
  tests MultiTenantSupport::Generators::InitializerGenerator
  destination File.expand_path('tmp/initializer', __dir__)
  setup :prepare_destination

  test "generator an initializer file" do
    assert Dir.children(destination_root).empty?
    run_generator
    initializer_file_content = File.read("#{destination_root}/config/initializers/multi_tenant_support.rb")
    expected_content = <<~INITIALIZER
    require 'multi_tenant_support'

    MultiTenantSupport.configure do
      model do |config|
        config.tenant_account_class_name = 'REPLACE_ME'
        config.tenant_account_primary_key = :id
      end

      controller do |config|
        config.current_tenant_account_method = :current_tenant_account
      end

      app do |config|
        config.excluded_subdomains = ['www']
        config.host = 'REPLACE.ME'
      end
    end

    # Uncomment if you are using sidekiq without ActiveJob
    # require 'multi_tenant_support/sidekiq'

    # Uncomment if you are using ActiveJob
    # require 'multi_tenant_support/active_job'
    INITIALIZER

    assert_equal expected_content, initializer_file_content
  end
end
