module MultiTenantSupport
  module ModelConcern
    extend ActiveSupport::Concern

    class_methods do

      def find_tenant_account(subdomains:, domain:)
        excluded_subdomains = MultiTenantSupport.configuration.excluded_subdomains
        subdomain = subdomains.select do |subdomain|
          excluded_subdomains.none? do |excluded_subdomain|
            excluded_subdomain.to_s.downcase == subdomain.to_s.downcase
          end
        end.last.presence

        subdomain ? find_by(subdomain: subdomain) : find_by(domain: domain)
      end

    end

  end
end

ActiveSupport.on_load(:active_record) do |base|
  base.include MultiTenantSupport::ModelConcern
end