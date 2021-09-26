module MultiTenantSupport
  class FindTenantAccount
    class << self

      def call(subdomains:, domain:)
        subdomain = subdomains.select do |subdomain|
          configuration.excluded_subdomains.none? do |excluded_subdomain|
            excluded_subdomain.to_s.downcase == subdomain.to_s.downcase
          end
        end.last.presence

        subdomain ? find_by(subdomain: subdomain) : find_by(domain: domain)
      end

      private

      def find_by(params)
        tenant_account_class.find_by(params)
      end

      def tenant_account_class
        configuration.tenant_account_class.constantize
      end

      def configuration
        MultiTenantSupport.configuration
      end

    end
  end
end