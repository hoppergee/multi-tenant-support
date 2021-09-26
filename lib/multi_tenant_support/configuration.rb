module MultiTenantSupport
  class Configuration
    attr_writer :tenant_account_class,
                :primary_key,
                :foreign_key,
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

    def current_tenant_account_method
      @current_tenant_account_method ||= :current_tenant_account
    end

    def primary_key
      @primary_key ||= :id
    end

    def foreign_key
      @foreign_key ||= "#{tenant_account_class.underscore}_id".to_sym
    end

    def host
      @host || raise("host is missing")
    end
  end
end