module MultiTenantSupport

  module Config
    class App
      attr_writer :excluded_subdomains,
                  :host

      def excluded_subdomains
        @excluded_subdomains ||= []
      end

      def host
        @host || raise("host is missing")
      end
    end
  end

  module_function
  def app
    @app ||= Config::App.new
    return @app unless block_given?

    yield @app
  end

end
