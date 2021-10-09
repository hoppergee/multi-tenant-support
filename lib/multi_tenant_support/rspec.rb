require_relative "./test/integration"
require_relative "./test/system"
require_relative "./test/capybara"

RSpec.configure do |config|
  config.include MultiTenantSupport::Test::Integration, type: :request
  config.include MultiTenantSupport::Test::Integration, type: :controller

  config.include MultiTenantSupport::Test::System, type: :system
  config.include MultiTenantSupport::Test::System, type: :feature
end

Capybara::Node::Element.prepend(MultiTenantSupport::Test::Capybara)
