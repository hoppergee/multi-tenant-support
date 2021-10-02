module MultiTenantSupport

  module Config
    class Controller
      attr_writer :current_tenant_account_method

      def current_tenant_account_method
        @current_tenant_account_method ||= :current_tenant_account
      end

    end
  end

  module_function
  def controller
    @controller ||= Config::Controller.new
    return @controller unless block_given?

    yield @controller
  end

  def current_tenant_account_method
    controller.current_tenant_account_method
  end

end
