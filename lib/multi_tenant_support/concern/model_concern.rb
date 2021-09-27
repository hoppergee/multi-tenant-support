module MultiTenantSupport
  module ModelConcern
    extend ActiveSupport::Concern

    class_methods do

      def belongs_to_tenant(name, **options)
        options[:foreign_key] ||= MultiTenantSupport.configuration.foreign_key
        belongs_to name.to_sym, **options

        set_default_scope_under_current_tenant(options[:foreign_key])
      end

      private

      def set_default_scope_under_current_tenant(foreign_key)
        default_scope lambda {
          if MultiTenantSupport.default_scope_on?
            raise "Current tenant is missing" unless MultiTenantSupport.current_tenant

            tenant_account_primary_key = MultiTenantSupport.configuration.primary_key
            tenant_account_id = MultiTenantSupport.current_tenant.send(tenant_account_primary_key)
            where(foreign_key => tenant_account_id)
          else
            where(nil)
          end
        }

        scope :unscope_tenant, -> { unscope(where: foreign_key) }
      end

    end

  end
end

ActiveSupport.on_load(:active_record) do |base|
  base.include MultiTenantSupport::ModelConcern
end