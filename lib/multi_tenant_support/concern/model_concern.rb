module MultiTenantSupport
  module ModelConcern
    extend ActiveSupport::Concern

    class_methods do

      def belongs_to_tenant(name, **options)
        options[:foreign_key] ||= MultiTenantSupport.model.default_foreign_key
        belongs_to name.to_sym, **options

        set_default_scope_under_current_tenant(options[:foreign_key])
        set_tenant_account_readonly(name, options[:foreign_key])

        MultiTenantSupport.model.tenanted_models << self.name
      end

      private

      def set_default_scope_under_current_tenant(foreign_key)
        default_scope lambda {
          if MultiTenantSupport.full_protected?
            scope_under_current_tenant
          else
            where(nil)
          end
        }

        scope :scope_under_current_tenant, lambda {
          raise MissingTenantError unless MultiTenantSupport.current_tenant

          tenant_account_primary_key = MultiTenantSupport.model.tenant_account_primary_key
          tenant_account_id = MultiTenantSupport.current_tenant.send(tenant_account_primary_key)
          where(foreign_key => tenant_account_id)
        }

        scope :unscope_tenant, -> { unscope(where: foreign_key) }

        override_unscoped = Module.new {
          define_method :unscoped do |&block|
            if MultiTenantSupport.full_protected?
              block ? relation.scope_under_current_tenant.scoping { block.call } : relation.scope_under_current_tenant
            else
              super(&block)
            end
          end
        }
        extend override_unscoped

        override_insert_all = Module.new {
          define_method :insert_all do |attributes, **arguments|
            raise MissingTenantError unless MultiTenantSupport.unprotected? || MultiTenantSupport.current_tenant

            super(attributes, **arguments)
          end

          define_method :insert_all! do |attributes, **arguments|
            raise MissingTenantError unless MultiTenantSupport.unprotected? || MultiTenantSupport.current_tenant

            super(attributes, **arguments)
          end
        }
        extend override_insert_all

        override_upsert_all = Module.new {
          define_method :upsert_all do |attributes, **arguments|
            warn "[WARNING] You are using upsert_all(or upsert) which may update records across tenants" unless MultiTenantSupport.unprotected?

            super(attributes, **arguments)
          end
        }
        extend override_upsert_all

        after_initialize do |object|
          next if object.new_record? && MultiTenantSupport.unprotected?
          next if object.persisted? && MultiTenantSupport.allow_read_across_tenant?

          raise MissingTenantError unless MultiTenantSupport.current_tenant
          raise InvalidTenantAccess if object.send(foreign_key) != MultiTenantSupport.current_tenant_id
        end

        before_save do |object|
          next if MultiTenantSupport.unprotected?

          raise MissingTenantError unless MultiTenantSupport.current_tenant
          raise NilTenantError if object.send(foreign_key).nil?
          raise InvalidTenantAccess if object.send(foreign_key) != MultiTenantSupport.current_tenant_id
        end

        override_update_columns_module = Module.new {
          define_method :update_columns do |attributes|
            unless MultiTenantSupport.unprotected?
              raise MissingTenantError unless MultiTenantSupport.current_tenant
              raise NilTenantError if send(foreign_key).nil?
              raise InvalidTenantAccess if send(foreign_key) != MultiTenantSupport.current_tenant_id
            end

            super(attributes)
          end
        }

        include override_update_columns_module

        override_delete = Module.new {
          define_method :delete do
            unless MultiTenantSupport.unprotected?
              raise MissingTenantError unless MultiTenantSupport.current_tenant
              raise InvalidTenantAccess if send(foreign_key) != MultiTenantSupport.current_tenant_id
            end

            super()
          end
        }
        include override_delete

        override_delete_by = Module.new {
          define_method :delete_by do |*args|
            unless MultiTenantSupport.unprotected?
              raise MissingTenantError unless MultiTenantSupport.current_tenant
            end

            super(*args)
          end
        }
        extend override_delete_by

        before_destroy do |object|
          unless MultiTenantSupport.unprotected?
            raise MissingTenantError unless MultiTenantSupport.current_tenant
            raise InvalidTenantAccess if object.send(foreign_key) != MultiTenantSupport.current_tenant_id
          end
        end
      end

      def set_tenant_account_readonly(tenant_name, foreign_key)
        readonly_tenant_module = Module.new {

          define_method "#{tenant_name}=" do |tenant|
            return super(tenant_account) if MultiTenantSupport.unprotected?

            raise NilTenantError if tenant.nil?
            raise MissingTenantError unless MultiTenantSupport.current_tenant


            if new_record? && tenant == MultiTenantSupport.current_tenant
              super tenant
            else
              raise ImmutableTenantError
            end
          end

          define_method "#{foreign_key}=" do |key|
            return super(tenant_account) if MultiTenantSupport.unprotected?

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

  override_delete_all = Module.new {
    define_method :delete_all do
      unless MultiTenantSupport.unprotected?
        current_tenant_exist = MultiTenantSupport.current_tenant
        is_global_model = !MultiTenantSupport.model.tenanted_models.include?(klass.name)
        raise MultiTenantSupport::MissingTenantError unless current_tenant_exist || is_global_model
      end

      super()
    end
  }
  ActiveRecord::Relation.prepend override_delete_all

  override_update_all = Module.new {
    define_method :update_all do |updates|
      unless MultiTenantSupport.unprotected?
        current_tenant_exist = MultiTenantSupport.current_tenant
        is_global_model = !MultiTenantSupport.model.tenanted_models.include?(klass.name)
        raise MultiTenantSupport::MissingTenantError unless current_tenant_exist || is_global_model
      end

      super(updates)
    end
  }
  ActiveRecord::Relation.prepend override_update_all
end