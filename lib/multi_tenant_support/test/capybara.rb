module MultiTenantSupport
  module Test
    module Capybara

      def set(value, **options)
        keep_context_tenant_unchange do
          super(value, **options)
        end
      end

      def select_option(wait: nil)
        keep_context_tenant_unchange do
          super(wait: wait)
        end
      end

      def unselect_option(wait: nil)
        keep_context_tenant_unchange do
          super(wait: wait)
        end
      end

      def perform_click_action(keys, wait: nil, **options)
        keep_context_tenant_unchange do
          super
        end
      end

      def trigger(event)
        keep_context_tenant_unchange do
          super
        end
      end

      def evaluate_script(script, *args)
        keep_context_tenant_unchange do
          super
        end
      end

      def evaluate_async_script(script, *args)
        keep_context_tenant_unchange do
          super
        end
      end

      def keep_context_tenant_unchange
        _current_tenant = MultiTenantSupport::Current.tenant_account
        MultiTenantSupport::Current.tenant_account = nil # Simulate real circumstance
        yield
      ensure
        MultiTenantSupport::Current.tenant_account = _current_tenant
      end

    end
  end
end

Capybara::Node::Element.prepend(MultiTenantSupport::Test::Capybara)