module MultiTenantSupport
  module DSL

    def within_a_request_of(tenant_account, &block)
      if tenant_account.is_a?(Symbol)
        raise "Unkown tenant" unless tenant_account == super_admin
  
        allow_read_across_tenant do
          under_tenant nil do
            yield
          end
        end
      else
        disallow_read_across_tenant do
          under_tenant tenant_account do
            yield
          end
        end
      end
    end
  
    def missing_tenant
      under_tenant nil do
        yield
      end
    end
  
    def under_tenant(tenant_account)
      MultiTenantSupport.under_tenant tenant_account do
        yield
      end
    end
  
    def disallow_read_across_tenant
      MultiTenantSupport.disallow_read_across_tenant do
        yield
      end
    end
  
    def allow_read_across_tenant
      MultiTenantSupport.allow_read_across_tenant do
        yield
      end
    end
  
    def super_admin
      :super_admin
    end

    def amazon
      accounts(:amazon)
    end
  
    def apple
      accounts(:apple)
    end
  
    def facebook
      accounts(:facebook)
    end

    def setup_users
      allow_read_across_tenant do
        @bezos = users(:bezos)
        @zuck = users(:zuck)
        @steve = users(:steve)
      end
    end
  
    def bezos
      @bezos
    end
  
    def zuck
      @zuck
    end
  
    def steve
      @steve
    end
  end
end