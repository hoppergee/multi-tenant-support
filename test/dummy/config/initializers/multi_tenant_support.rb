MultiTenantSupport.configure do |config|
  config.tenant_account_class = 'Account'
  config.primary_key = :id
  config.excluded_models = ['Account']
  config.excluded_subdomains = ['www']
  config.current_tenant_account_method = :current_tenant_account
  config.host = 'example.com'
end