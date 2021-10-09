module MultiTenantSupport
  module Test
    module Integration

      %i[get post patch put delete head options].each do |method|
        define_method method do |path, **args|
          keep_context_tenant_unchange do
            super(path, **args)
          end
        end
      end
    
      def follow_redirect(**args)
        keep_context_tenant_unchange do
          super(**args)
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
