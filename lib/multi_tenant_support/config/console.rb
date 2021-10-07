module MultiTenantSupport

  module Config
    class Console
      attr_writer :allow_read_across_tenant_by_default

      def allow_read_across_tenant_by_default
        @allow_read_across_tenant_by_default ||= false
      end
    end
  end

  module_function
  def console
    @console ||= Config::Console.new
    return @console unless block_given?

    yield @console
  end

end
