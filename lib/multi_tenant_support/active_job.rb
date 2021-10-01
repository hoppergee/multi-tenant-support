module MultiTenantSupport
  module ActiveJob
    extend ActiveSupport::Concern

    included do
      attr_accessor :current_tenant
    end

    def perform_now
      MultiTenantSupport.under_tenant(current_tenant) do
        super
      end
    end

    def serialize
      if MultiTenantSupport.current_tenant
        super.merge({
          "multi_tenant_support" => {
            "id" => MultiTenantSupport.current_tenant.id,
            "class" => MultiTenantSupport.current_tenant.class.name
          }
        })
      else
        super
      end
    end

    def deserialize(job_data)
      self.current_tenant = find_current_tenant(job_data)
      MultiTenantSupport.under_tenant(current_tenant) do
        super
      end
    end

    private

    def find_current_tenant(data)
      return unless data.has_key?("multi_tenant_support")

      tenant_klass = data["multi_tenant_support"]["class"].constantize
      tenant_id = data["multi_tenant_support"]["id"]

      tenant_klass.find tenant_id
    end
  end
end

ActiveJob::Base.include(MultiTenantSupport::ActiveJob)