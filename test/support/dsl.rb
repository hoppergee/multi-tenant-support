module MultiTenantSupport
  module DSL

    def within_a_request_of(tenant_account, &block)
      if tenant_account.is_a?(Symbol)
        raise "Unkown tenant" unless tenant_account == super_admin
  
        as_super_admin do
          yield
        end
      else
        under_tenant tenant_account do
          yield
        end
      end
    end
  
    def missing_tenant
      without_current_tenant do
        yield
      end
    end
  
    def under_tenant(tenant_account)
      MultiTenantSupport.under_tenant tenant_account do
        yield
      end
    end
  
    def turn_on_full_protection
      MultiTenantSupport.turn_on_full_protection do
        yield
      end
    end
  
    def allow_read_across_tenant
      MultiTenantSupport.allow_read_across_tenant do
        yield
      end
    end

    def without_current_tenant
      MultiTenantSupport.without_current_tenant do
        yield
      end
    end

    def as_super_admin
      without_current_tenant do
        allow_read_across_tenant do
          yield
        end
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