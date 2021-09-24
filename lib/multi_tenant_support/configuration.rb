module MultiTenantSupport
  class Configuration
    attr_writer :tenant_account_class,
                :primary_key,
                :excluded_models,
                :excluded_subdomains,
                :current_tenant_account_method,
                :domain,
                :host

    def tenant_account_class
      @tenant_account_class || raise("tenant_account_class is missing")
    end

    def excluded_subdomains
      @excluded_subdomains ||= []
    end

    def excluded_models
      @excluded_models ||= []
    end

    def current_tenant_account_method
      @current_tenant_account_method ||= :current_tenant_account
    end

    def primary_key
      @primary_key ||= :id
    end

    def host
      @host || raise("host is missing")
    end
  end
end