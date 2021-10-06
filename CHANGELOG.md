## [Unreleased]

## [1.0.5] - 2021-10-06

- Fix an error caused by call `helper_method` on ActionController::API

## [1.0.4] - 2021-10-05

- Rename "lib/multi_tenant_support.rb" to "lib/multi-tenant-support.rb"
- Breaking: please remove `require 'multi_tenant_support'` from the `config/initializers/multi_tenant_support.rb`

## [1.0.3] - 2021-10-04

- Prevent most ActiveRecord CRUD methods from acting across tenants.
- Support Row-level Multitenancy
- Build on ActiveSupport::CurrentAttributes offered by rails
- Auto set current tenant through subdomain and domain in controller
- Support ActiveJob and Sidekiq
