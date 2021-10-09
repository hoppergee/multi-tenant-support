module MultiTenantSupport
  module Test
    module System

      %i[
        visit refresh click_on go_back go_forward
        check choose click_button click_link
        fill_in uncheck check unselect select
        execute_script evaluate_script
      ].each do |method|
        if RUBY_VERSION >= '2.7'
          class_eval <<~METHOD, __FILE__, __LINE__ + 1
            def #{method}(...)
              keep_context_tenant_unchange do
                super(...)
              end
            end
          METHOD
        else
          define_method method do |*args, &block|
            keep_context_tenant_unchange do
              super(*args, &block)
            end
          end
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

ActionDispatch::SystemTestCase.prepend(MultiTenantSupport::Test::System)
