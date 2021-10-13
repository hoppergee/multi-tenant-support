## [Unreleased]

#### Add

- `MultiTenantSupport.set_current_tenant`
- `MultiTenantSupport.without_current_tenant`
- `MultiTenantSupport.full_protected?`
- `MultiTenantSupport.unprotected?`
- `MultiTenantSupport.turn_off_protection`
- `MultiTenantSupport.turn_on_full_protection`

#### Remove

- `MultiTenantSupport.disallow_read_across_tenant?`

## [1.3.1] - 2021-10-10

- Make ViewHelper work in both controller and view

## [1.3.0] - 2021-10-10

- Integrate with Rails default testing toolchain (Minitest + Capybara)
- Integrate with RSpec + Capybara

## [1.2.0] - 2021-10-08

- Keep current tenant unchange around job perform with SiekiqAdapter,TestAdapter,InlineAdapter,AsyncAdapter
- Add a new console config `allow_read_across_tenant_by_default`
- Add an environment varialbe `ALLOW_READ_ACROSS_TENANT`

## [1.1.1] - 2021-10-07

- Make sure all four job delivery ways work as expected
  - MyJob.perform_now('hi')
  - MyJob.perform_later('hi')
  - MyJob.set(queue: 'high').perform_now('hi')
  - MyJob.set(queue: 'high').perform_later('hi')

## [1.1.0] - 2021-10-07

- Make tenant finding strategy customizable
  - Override `find_current_tenant_account` in controller

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
