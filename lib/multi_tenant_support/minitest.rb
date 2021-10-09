require_relative "./test/integration"
require_relative "./test/system"
require_relative "./test/capybara"

ActionDispatch::IntegrationTest.prepend(MultiTenantSupport::Test::Integration)
ActionDispatch::SystemTestCase.prepend(MultiTenantSupport::Test::System)
Capybara::Node::Element.prepend(MultiTenantSupport::Test::Capybara)