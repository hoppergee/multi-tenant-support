module MultiTenantSupport
  class Railtie < ::Rails::Railtie

    initializer :add_generator_templates do
      override_templates = File.expand_path("../generators/override", __dir__)
      config.app_generators.templates.unshift(override_templates)

      active_record_templates = File.expand_path("../generators/override/active_record", __dir__)
      config.app_generators.templates.unshift(active_record_templates)
    end

  end
end
