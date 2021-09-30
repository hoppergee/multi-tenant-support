module MultiTenantSupport
  module Sidekiq

    class Client
      def call(worker_class, msg, queue, redis_pool)
        if MultiTenantSupport.current_tenant.present?
          msg["multi_tenant_support"] ||= {
            "class" => MultiTenantSupport.current_tenant.class.name,
            "id" => MultiTenantSupport.current_tenant.id
          }
        end

        yield
      end
    end

    class Server
      def call(worker_instance, msg, queue)
        if msg.has_key?("multi_tenant_support")
          tenant_klass = msg["multi_tenant_support"]["class"].constantize
          tenant_id = msg["multi_tenant_support"]["id"]
          
          tenant_account = tenant_klass.find tenant_id

          MultiTenantSupport.under_tenant tenant_account do
            yield
          end
        else
          yield
        end
      end
    end

  end
end

Sidekiq.configure_client do |config|
  config.client_middleware do |chain|
    chain.add MultiTenantSupport::Sidekiq::Client
  end
end

Sidekiq.configure_server do |config|
  config.client_middleware do |chain|
    chain.add MultiTenantSupport::Sidekiq::Client
  end

  config.server_middleware do |chain|
    if defined?(Sidekiq::Middleware::Server::RetryJobs)
      chain.insert_before Sidekiq::Middleware::Server::RetryJobs, MultiTenantSupport::Sidekiq::Server
    elsif defined?(Sidekiq::Batch::Server)
      chain.insert_before Sidekiq::Batch::Server, MultiTenantSupport::Sidekiq::Server
    else
      chain.add MultiTenantSupport::Sidekiq::Server
    end
  end
end