# MultiTenantSupport

Build a highly secure, multi-tenant rails app without data leak.

Keep your data secure with multi-tenant-support. Prevent most ActiveRecord CRUD methods to action across tenant, ensuring no one can accidentally or intentionally access other tenants' data. This can be crucial for applications handling sensitive information like financial information, intellectual property, and so forth.

- Prevent most ActiveRecord CRUD methods from acting across tenants.
- Support Row-level Multitenancy
- Build on ActiveSupport::CurrentAttributes offered by rails
- Auto set current tenant through subdomain and domain in controller
- Support ActiveJob and Sidekiq

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
    rails generate multi_tenant_support:migration
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

## Example

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
