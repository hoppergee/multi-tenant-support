# MultiTenantSupport

[![Test](https://github.com/hoppergee/multi-tenant-support/actions/workflows/main.yaml/badge.svg?branch=main&event=release)](https://github.com/hoppergee/multi-tenant-support/actions/workflows/main.yaml)

Build a highly secure, multi-tenant rails app without data leak.

Keep your data secure with multi-tenant-support. Prevent most ActiveRecord CRUD methods to action across tenant, ensuring no one can accidentally or intentionally access other tenants' data. This can be crucial for applications handling sensitive information like financial information, intellectual property, and so forth.

- Prevent most ActiveRecord CRUD methods from acting across tenants.
- Support Row-level Multitenancy
- Build on ActiveSupport::CurrentAttributes offered by rails
- Auto set current tenant through subdomain and domain in controller
- Support ActiveJob and Sidekiq

| Model methods                      | Protect     |
| ---------------------------------- | ----------- |
| count                              | 🔒           |
| first                              | 🔒           |
| last                               | 🔒           |
| where                              | 🔒           |
| find_by                            | 🔒           |
| reload                             | 🔒           |
| new                                | 🔒           |
| build                              | 🔒           |
| save, save!, save(validate: false) | 🔒           |
| create, create!                    | 🔒           |
| insert, insert!                    | 🔒           |
| insert_all, insert_all!            | 🔒           |
| `ACCOUNT=`, `ACCOUNT_ID=`          | 🔒           |
| update                             | 🔒           |
| update_all                         | 🔒           |
| update_attribute                   | 🔒           |
| update_columns                     | 🔒           |
| update_column                      | 🔒           |
| upsert_all                         | ⚠️ (Partial) |
| upsert                             | 🔒           |
| destroy, destroy!                  | 🔒           |
| destroy_all                        | 🔒           |
| destroy_by                         | 🔒           |
| delete_all                         | 🔒           |
| delete_by                          | 🔒           |
| unscoped                           | 🔒           |

## Installation

1. Add this line to your application's Gemfile:

    ```ruby
    gem 'multi-tenant-support'
    ```

2. And then execute:

    ```
    bundle install
    ```

3. Add domain and subdomain to your tenant account table (Skip if your rails app already did this)

    ```
    rails generate multi_tenant_support:migration YOUR_TENANT_ACCOUNT_TABLE_OR_MODEL_NAME

    # Say your tenant account table is "accounts"
    rails generate multi_tenant_support:migration accounts

    # You can also run it with the tenant account model name
    # rails generate multi_tenant_support:migration Account

    rails db:migrate
    ```

4. Create an initializer

    ```
    rails generate multi_tenant_support:initializer
    ```

5. Set `tenant_account_class_name` to your tenant account model name in `multi_tenant_support.rb`

    ```ruby
    --- config.tenant_account_class_name = 'REPLACE_ME'
    +++ config.tenant_account_class_name = 'Account'
    ```

6. Set `host` to your app's domain in `multi_tenant_support.rb`

    ```ruby
    --- config.host = 'REPLACE.ME'
    +++ config.host = 'your-app-domain.com'
    ```

7. Setup for ActiveJob or Sidekiq

    If you are using ActiveJob

    ```ruby
    --- # require 'multi_tenant_support/active_job'
    +++ require 'multi_tenant_support/active_job'
    ```

    If you are using sidekiq without ActiveJob

    ```ruby
    --- # require 'multi_tenant_support/sidekiq'
    +++ require 'multi_tenant_support/sidekiq'
    ```

8. Add `belongs_to_tenant` to all models which you want to scope under tenant

    ```ruby
    class User < ApplicationRecord
      belongs_to_tenant :account
    end
    ```

## Usage

#### Get current 

Get current tenant through:

```ruby
MultiTenantSupport.current_tenant
```

#### Switch tenant

You can switch to another tenant temporary through:

```ruby
MultiTenantSupport.under_tenant amazon do
  # Do things under amazon account
end
```

#### Disallow read across tenant by default

This gem disallow read across tenant by default. You can check current state through:

```ruby
MultiTenantSupport.disallow_read_across_tenant?
```

#### Allow read across tenant for super admin

You can turn on the permission to read records across tenant through: 

```ruby
MultiTenantSupport.allow_read_across_tenant

# Or
MultiTenantSupport.allow_read_across_tenant do
  # ...
end
```

You can put it in a before action in SuperAdmin's controllers

#### Disallow modify records tenant

This gem disallow modify record across tenant no matter you are super admin or not.

If `MultiTenantSupport.current_tenant` exist, you can only modify those records under this tenant, otherwise, you will get some errors like:

- `MultiTenantSupport::MissingTenantError`
- `MultiTenantSupport::ImmutableTenantError`
- `MultiTenantSupport::NilTenantError`
- `MultiTenantSupport::InvalidTenantAccess`
- `ActiveRecord::RecordNotFound`

If `MultiTenantSupport.current_tenant` is missing, you cannot modify or create any tenanted records.

#### Set current tenant acccount in controller by default

This gem has set a before action `set_current_tenant_account` on ActionController. It search tenant by subdomain or domain. Do remember to `skip_before_action :set_current_tenant_account` in super admin controllers.

Feel free to override it, if the finder behaviour is not what you want.

#### upsert_all

Currently, we don't have a good way to protect this method. So please use `upser_all` carefully.

#### Unscoped

This gem has override `unscoped` to prevent the default tenant scope be scoped out. But if you really want to scope out the default tenant scope, you can use `unscope_tenant`.

## Code Example

#### Database Schema

```ruby
create_table "accounts", force: :cascade do |t|
  t.bigint "domain"
  t.bigint "subdomain"
end

create_table "users", force: :cascade do |t|
  t.bigint "account_id"
end
```

#### Initializer

```ruby
# config/initializers/multi_tenant_support.rb

MultiTenantSupport.configure do
  model do |config|
    config.tenant_account_class_name = 'Account'
    config.tenant_account_primary_key = :id
  end

  controller do |config|
    config.current_tenant_method_name = :current_tenant_account
  end

  app do |config|
    config.excluded_subdomains = ['www']
    config.host = 'example.com'
  end
end
```

#### Model

```ruby
class Account < AppplicationRecord
  has_many :users
end

class User < ApplicationRecord
  belongs_to_tenant :account
end
```

#### Controler

```ruby
class UsersController < ApplicationController
  def show
    @user = User.find(params[:id]) # This result is already scope under current_tenant_account
    @you_can_get_account = current_tenant_account
  end
end
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/hoppergee/multi_tenant_support.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
