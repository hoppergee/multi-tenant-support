module MultiTenantSupport
  module ModelConcern
    extend ActiveSupport::Concern

    class_methods do

      def belongs_to_tenant(name, **options)
        options[:foreign_key] ||= MultiTenantSupport.configuration.foreign_key
        belongs_to name.to_sym, **options

        set_default_scope_under_current_tenant(options[:foreign_key])
        set_tenant_account_readonly(name, options[:foreign_key])
      end

      private

      def set_default_scope_under_current_tenant(foreign_key)
        default_scope lambda {
          if MultiTenantSupport.disallow_read_across_tenant?
            raise MissingTenantError unless MultiTenantSupport.current_tenant

            tenant_account_primary_key = MultiTenantSupport.configuration.primary_key
            tenant_account_id = MultiTenantSupport.current_tenant.send(tenant_account_primary_key)
            where(foreign_key => tenant_account_id)
          else
            where(nil)
          end
        }

        scope :unscope_tenant, -> { unscope(where: foreign_key) }

        after_initialize do |object|
          if MultiTenantSupport.disallow_read_across_tenant? || object.new_record?
            raise MissingTenantError unless MultiTenantSupport.current_tenant
            raise InvalidTenantAccess if object.send(foreign_key) != MultiTenantSupport.current_tenant_id
          end
        end

        before_save do |object|
          raise NilTenantError if object.send(foreign_key).nil?
          raise InvalidTenantAccess if object.send(foreign_key) != MultiTenantSupport.current_tenant_id
        end

        override_update_columns_module = Module.new {
          define_method :update_columns do |attributes|
            raise NilTenantError if send(foreign_key).nil?
            raise InvalidTenantAccess if send(foreign_key) != MultiTenantSupport.current_tenant_id

            super(attributes)
          end

          define_method :update_column do |name, value|
            raise NilTenantError if send(foreign_key).nil?
            raise InvalidTenantAccess if send(foreign_key) != MultiTenantSupport.current_tenant_id

            super(name, value)
          end
        }

        include override_update_columns_module

        before_destroy do |object|
          raise InvalidTenantAccess if object.send(foreign_key) != MultiTenantSupport.current_tenant_id
        end
      end

      def set_tenant_account_readonly(tenant_name, foreign_key)
        readonly_tenant_module = Module.new {

          define_method "#{tenant_name}=" do |tenant|
            raise NilTenantError if tenant.nil?
            raise MissingTenantError unless MultiTenantSupport.current_tenant

            if new_record? && tenant == MultiTenantSupport.current_tenant
              super tenant
            else
              raise ImmutableTenantError
            end
          end

          define_method "#{foreign_key}=" do |key|
            raise NilTenantError if key.nil?
            raise MissingTenantError unless MultiTenantSupport.current_tenant

            if new_record? && key == MultiTenantSupport.current_tenant_id
              super key
            else
              raise ImmutableTenantError
            end
          end

        }

        include readonly_tenant_module

        attr_readonly foreign_key
      end

    end

  end
end

ActiveSupport.on_load(:active_record) do |base|
  base.include MultiTenantSupport::ModelConcern
end