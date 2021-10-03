module MultiTenantSupport
  module Config

    class Model
      attr_writer :tenant_account_class_name,
                  :tenant_account_primary_key,
                  :default_foreign_key,
                  :tenanted_models

      def tenant_account_class_name
        @tenant_account_class_name || raise("tenant_account_class_name is missing")
      end

      def tenant_account_primary_key
        @tenant_account_primary_key ||= :id
      end

      def default_foreign_key
        @default_foreign_key ||= "#{tenant_account_class_name.underscore}_id".to_sym
      end

      def tenanted_models
        @tenanted_models ||= []
      end
    end

  end

  module_function
  def model
    @model ||= Config::Model.new
    return @model unless block_given?

    yield @model
  end
end
