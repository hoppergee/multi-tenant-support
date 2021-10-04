require_relative "lib/multi_tenant_support/version"

Gem::Specification.new do |spec|
  spec.name        = "multi-tenant-support"
  spec.version     = MultiTenantSupport::VERSION
  spec.authors     = ["Hopper Gee"]
  spec.email       = ["hopper.gee@hey.com"]
  spec.homepage    = "https://github.com/hoppergee/multi-tenant-support"
  spec.summary     = "Build a highly secure, multi-tenant rails app without data leak."
  spec.description = "Build a highly secure, multi-tenant rails app without data leak."
  spec.license     = "MIT"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/hoppergee/multi-tenant-support"
  spec.metadata["changelog_uri"] = "https://github.com/hoppergee/multi-tenant-support/blob/main/CHANGELOG.md"

  spec.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.md"]

  spec.required_ruby_version = '>= 2.6'

  spec.add_dependency "rails", ">= 6.0"
end
