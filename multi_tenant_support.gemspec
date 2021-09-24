require_relative "lib/multi_tenant_support/version"

Gem::Specification.new do |spec|
  spec.name        = "multi_tenant_support"
  spec.version     = MultiTenantSupport::VERSION
  spec.authors     = ["Hopper Gee"]
  spec.email       = ["hopper.gee@hey.com"]
  spec.homepage    = "TODO"
  spec.summary     = "TODO: Summary of MultiTenantSupport."
  spec.description = "TODO: Description of MultiTenantSupport."
  spec.license     = "MIT"

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  spec.metadata["allowed_push_host"] = "TODO: Set to 'http://mygemserver.com'"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "TODO: Put your gem's public repo URL here."
  spec.metadata["changelog_uri"] = "TODO: Put your gem's CHANGELOG.md URL here."

  spec.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.md"]

  spec.add_dependency "rails", "~> 6.1.4"
end
