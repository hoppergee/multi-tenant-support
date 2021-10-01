require_relative "lib/multi_tenant_support/version"

Gem::Specification.new do |spec|
  spec.name        = "multi-tenant-support"
  spec.version     = MultiTenantSupport::VERSION
  spec.authors     = ["Hopper Gee"]
  spec.email       = ["hopper.gee@hey.com"]
  spec.homepage    = "https://github.com/hoppergee/multi-tenant-support"
  spec.summary     = "Multi-tenant buid on ActiveSupport::CurrentAttributes for Rails apps."
  spec.description = "Multi-tenant buid on ActiveSupport::CurrentAttributes for Rails apps."
  spec.license     = "MIT"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/hoppergee/multi-tenant-support"
  spec.metadata["changelog_uri"] = "https://github.com/hoppergee/multi-tenant-support/blob/main/CHANGELOG.md"

  spec.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.md"]

  spec.add_dependency "rails", "~> 6.1.4"
end
