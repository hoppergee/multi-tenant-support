## [Unreleased]

## [1.0.3] - 2021-10-04

- Prevent most ActiveRecord CRUD methods from acting across tenants.
- Support Row-level Multitenancy
- Build on ActiveSupport::CurrentAttributes offered by rails
- Auto set current tenant through subdomain and domain in controller
- Support ActiveJob and Sidekiq
