# MultiTenantSupport

[![Test](https://github.com/hoppergee/multi-tenant-support/actions/workflows/main.yaml/badge.svg?branch=main)](https://github.com/hoppergee/multi-tenant-support/actions/workflows/main.yaml) [![Gem Version](https://badge.fury.io/rb/multi-tenant-support.svg)](https://badge.fury.io/rb/multi-tenant-support)

![](https://raw.githubusercontent.com/hoppergee/multi-tenant-support/main/hero.png)

Build a highly secure, multi-tenant rails app without data leak.

Keep your data secure with multi-tenant-support. Prevent most ActiveRecord CRUD methods to action across tenant, ensuring no one can accidentally or intentionally access other tenants' data. This can be crucial for applications handling sensitive information like financial information, intellectual property, and so forth.

- Prevent most ActiveRecord CRUD methods from acting across tenants.
- Support Row-level Multitenancy
- Build on ActiveSupport::CurrentAttributes offered by rails
- Auto set current tenant through subdomain and domain in controller (overrideable)
- Support ActiveJob and Sidekiq



This gem was inspired much from [acts_as_tenant](https://github.com/ErwinM/acts_as_tenant), [multitenant](https://github.com/wireframe/multitenant), [multitenancy](https://github.com/Flipkart/multitenancy/blob/master/lib/multitenancy/model_extensions.rb), [rails-multitenant](https://github.com/salsify/rails-multitenant), [activerecord-firewall](https://github.com/Shopify/activerecord-firewall), [milia](https://github.com/jekuno/milia).

But it does more than them, and highly focuses on ActiveRecord data leak protection.



## What make it differnce on details

It protects data in every scenario in great detail. Currently, you can't find any multi-tenant gems doing a full data leak protect on ActiveRecord. But this gem does it.


Our protection code mainly focus on 5 scenarios:

- Action by tenant
  - `CurrentTenantSupport.current_tenant` exists
  - `CurrentTenantSupport.allow_read_across_tenant` is false (default)
- Action by wrong tenant
  - `CurrentTenantSupport.current_tenant` does not match `target_record.account`
  - `CurrentTenantSupport.allow_read_across_tenant` is false (default)
- Action when missing tenant
  - `CurrentTenantSupport.current_tenant` is nil
  - `CurrentTenantSupport.allow_read_across_tenant` is false (default)
- Action by super admin but readonly
  - `CurrentTenantSupport.current_tenant` is nil
  - `CurrentTenantSupport.allow_read_across_tenant` is true
- Action by super admin but want modify on a specific tenant
  - `CurrentTenantSupport.current_tenant` is nil
  - `CurrentTenantSupport.allow_read_across_tenant` is true
  - Run code in the block of `CurrentTenantSupport.under_tenant`


Below are the behaviour of all ActiveRecord CRUD methods under abvove scenarios:

### Protect on read


| Read By  | tenant | missing tenant | super admin | super admin(modify on a specific tenant) |
| -------- | ------ | -------------- | ----------- | ---------------------------------------- |
| count    | 🍕      | 🚫              | 🌎           | 🍕                                        |
| first    | 🍕      | 🚫              | 🌎           | 🍕                                        |
| last     | 🍕      | 🚫              | 🌎           | 🍕                                        |
| where    | 🍕      | 🚫              | 🌎           | 🍕                                        |
| find_by  | 🍕      | 🚫              | 🌎           | 🍕                                        |
| unscoped | 🍕      | 🚫              | 🌎           | 🍕                                        |

🍕   scoped  &#8203; &#8203; &#8203;  🌎   &#8203;   unscoped    &#8203; &#8203; &#8203;    ✅    &#8203; allow     &#8203; &#8203; &#8203;   🚫  &#8203; disallow   &#8203; &#8203; &#8203;    ⚠️ &#8203;  Not protected

<br>

### Protect on initialize

| Initialize by | tenant | wrong tenant | missing tenant | super admin | super admin(modify on a specific tenant) |
| ------------------ | ------ | ------------ | -------------- | ----------- | ---------------------------------------- |
| new                | ✅  &#8203; 🍕   | -            | 🚫              | 🚫           | ✅  &#8203; 🍕                                     |
| build              | ✅  &#8203; 🍕   | -           | 🚫              | 🚫           | ✅  &#8203; 🍕                                     |
| reload  | ✅ | 🚫            | 🚫              | ✅          | ✅ |

🍕   scoped  &#8203; &#8203; &#8203;  🌎   &#8203;   unscoped    &#8203; &#8203; &#8203;    ✅    &#8203; allow     &#8203; &#8203; &#8203;   🚫  &#8203; disallow   &#8203; &#8203; &#8203;    ⚠️ &#8203;  Not protected

<br>


### Protect on create

| create by   | tenant | wrong tenant | missing tenant | super admin | super admin(modify on a specific tenant) |
| ----------- | ------ | ------------ | -------------- | ----------- | ---------------------------------------- |
| save        | ✅  &#8203; 🍕   | 🚫            | 🚫              | 🚫           | ✅  &#8203; 🍕                                     |
| save!       | ✅  &#8203; 🍕   | 🚫            | 🚫              | 🚫           | ✅  &#8203; 🍕                                     |
| create      | ✅  &#8203; 🍕   | -            | 🚫              | 🚫           | ✅  &#8203; 🍕                                     |
| create!     | ✅  &#8203; 🍕   | -            | 🚫              | 🚫           | ✅  &#8203; 🍕                                     |
| insert      | ✅  &#8203; 🍕   | -            | 🚫              | 🚫           | ✅  &#8203; 🍕                                     |
| insert!     | ✅  &#8203; 🍕   | -            | 🚫              | 🚫           | ✅  &#8203; 🍕                                     |
| insert_all  | ✅  &#8203; 🍕   | -            | 🚫              | 🚫           | ✅  &#8203; 🍕                                     |
| insert_all! | ✅  &#8203; 🍕   | -            | 🚫              | 🚫           | ✅  &#8203; 🍕                                     |

🍕   scoped  &#8203; &#8203; &#8203;  🌎   &#8203;   unscoped    &#8203; &#8203; &#8203;    ✅    &#8203; allow     &#8203; &#8203; &#8203;   🚫  &#8203; disallow   &#8203; &#8203; &#8203;    ⚠️ &#8203;  Not protected

<br>


### Protect on tenant assign

| Manual assign or update tenant by | tenant | missing tenant | super admin | super admin(modify on a specific tenant) |
| --------------------------------- | ------ | -------------- | ----------- | ---------------------------------------- |
| account=                          | 🚫      | 🚫              | 🚫           | 🚫                                        |
| account_id=                       | 🚫      | 🚫              | 🚫           | 🚫                                        |
| update(account:)                  | 🚫      | 🚫              | 🚫           | 🚫                                        |
| update(account_id:)               | 🚫      | 🚫              | 🚫           | 🚫                                        |

🍕   scoped  &#8203; &#8203; &#8203;  🌎   &#8203;   unscoped    &#8203; &#8203; &#8203;    ✅    &#8203; allow     &#8203; &#8203; &#8203;   🚫  &#8203; disallow   &#8203; &#8203; &#8203;    ⚠️ &#8203;  Not protected

<br>


### Protect on update

| Update by        | tenant | wrong tenant | missing tenant | super admin | super admin(modify on a specific tenant) |
| ---------------- | ------ | ------------ | -------------- | ----------- | ---------------------------------------- |
| save        | ✅   | 🚫            | 🚫              | 🚫           | ✅                                      |
| save!       | ✅   | 🚫            | 🚫              | 🚫           | ✅                                      |
| update           | ✅      | 🚫            | 🚫              | 🚫           | ✅                                        |
| update_all       | ✅  &#8203; 🍕   | -            | 🚫              | 🚫           | ✅  &#8203; 🍕                                     |
| update_attribute | ✅      | 🚫            | 🚫              | 🚫           | ✅                                        |
| update_columns   | ✅      | 🚫            | 🚫              | 🚫           | ✅                                        |
| update_column    | ✅      | 🚫            | 🚫              | 🚫           | ✅                                        |
| upsert_all       | ⚠️      | -            | 🚫              | ⚠️           | ⚠️                                        |
| upsert           | ⚠️      | -            | 🚫              | ⚠️           | ⚠️                                        |

🍕   scoped  &#8203; &#8203; &#8203;  🌎   &#8203;   unscoped    &#8203; &#8203; &#8203;    ✅    &#8203; allow     &#8203; &#8203; &#8203;   🚫  &#8203; disallow   &#8203; &#8203; &#8203;    ⚠️ &#8203;  Not protected

<br>


### Protect on delete

| Delete by   | tenant | wrong tenant | missing tenant | super admin | super admin(modify on a specific tenant) |
| ----------- | ------ | ------------ | -------------- | ----------- | ---------------------------------------- |
| destroy     | ✅      | 🚫            | 🚫              | 🚫           | ✅                                        |
| destroy!    | ✅      | 🚫            | 🚫              | 🚫           | ✅                                        |
| destroy_all | ✅  &#8203; 🍕   | -            | 🚫              | 🚫           | ✅  &#8203; 🍕                                     |
| destroy_by  | ✅  &#8203; 🍕   | -            | 🚫              | 🚫           | ✅  &#8203; 🍕                                     |
| delete_all  | ✅  &#8203; 🍕   | -            | 🚫              | 🚫           | ✅  &#8203; 🍕                                     |
| delete_by   | ✅  &#8203; 🍕   | -            | 🚫              | 🚫           | ✅  &#8203; 🍕                                     |

🍕   scoped  &#8203; &#8203; &#8203;  🌎   &#8203;   unscoped    &#8203; &#8203; &#8203;    ✅    &#8203; allow     &#8203; &#8203; &#8203;   🚫  &#8203; disallow   &#8203; &#8203; &#8203;    ⚠️ &#8203;  Not protected

<br>


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
    - config.tenant_account_class_name = 'REPLACE_ME'
    + config.tenant_account_class_name = 'Account'
    ```

6. Set `host` to your app's domain in `multi_tenant_support.rb`

    ```ruby
    - config.host = 'REPLACE.ME'
    + config.host = 'your-app-domain.com'
    ```

7. Setup for ActiveJob or Sidekiq

    If you are using ActiveJob

    ```ruby
    - # require 'multi_tenant_support/active_job'
    + require 'multi_tenant_support/active_job'
    ```

    If you are using sidekiq without ActiveJob

    ```ruby
    - # require 'multi_tenant_support/sidekiq'
    + require 'multi_tenant_support/sidekiq'
    ```

8. Add `belongs_to_tenant` to all models which you want to scope under tenant

    ```ruby
    class User < ApplicationRecord
      belongs_to_tenant :account
    end
    ```

## Usage

### Get current

Get current tenant through:

```ruby
MultiTenantSupport.current_tenant
```

### Switch tenant

You can switch to another tenant temporary through:

```ruby
MultiTenantSupport.under_tenant amazon do
  # Do things under amazon account
end
```

### Set current tenant global

```ruby
MultiTenantSupport.set_tenant_account(account)
```

### Temp set current tenant to nil

```ruby
MultiTenantSupport.without_current_tenant do
  # ...
end
```

### 3 protection states

1. `MultiTenantSupport.full_protected?`
2. `MultiTenantSupport.allow_read_across_tenant?`
3. `MultiTenantSupport.unprotected?`

#### Full protection(default)

The default state is full protection. This gem disallow modify record across tenant by default.

If `MultiTenantSupport.current_tenant` exist, you can only modify those records under this tenant, otherwise, you will get some errors like:

- `MultiTenantSupport::MissingTenantError`
- `MultiTenantSupport::ImmutableTenantError`
- `MultiTenantSupport::NilTenantError`
- `MultiTenantSupport::InvalidTenantAccess`
- `ActiveRecord::RecordNotFound`

If `MultiTenantSupport.current_tenant` is missing, you cannot modify or create any tenanted records.

If you switched to other state, you can switch back through:

```ruby
MultiTenantSupport.turn_on_full_protection

# Or
MultiTenantSupport.turn_on_full_protection do
  # ...
end
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

#### Turn off protection

Sometimes, as a super admin, we need to execute certain maintenance operations over all tenant records. You can do this through:

```ruby
MultiTenantSupport.turn_off_protection

# Or
MultiTenantSupport.turn_off_protection do
  # ...
end
```

### Set current tenant acccount in controller by default

This gem has set a before action `set_current_tenant_account` on ActionController. It search tenant by subdomain or domain. Do remember to `skip_before_action :set_current_tenant_account` in super admin controllers.

Feel free to override it, if the finder behaviour is not what you want.

### Override current tenant finder method if domain/subdomain is not the way you want

You can override `find_current_tenant_account` in any controller with your own tenant finding strategy. Just make sure this method return the tenat account record or nil.

For example, say you only want to find tenant with domain not subdomain. It's very simple:

```ruby
class ApplicationController < ActionController::Base
  private

  def find_current_tenant_account
    Account.find_by(domain: request.domain)
  end
end
```

Then your tenant finding strategy has changed from domain/subdomain to domain only.

### upsert_all

Currently, we don't have a good way to protect this method. So please use `upser_all` carefully.

### Unscoped

This gem has override `unscoped` to prevent the default tenant scope be scoped out. But if you really want to scope out the default tenant scope, you can use `unscope_tenant`.

### Console

Console does not allow read across tenant by default. But you have several ways to change that:

1. Set `allow_read_across_tenant_by_default` in the initialize file

    ```ruby
    console do |config|
      config.allow_read_across_tenant_by_default = true
    end
    ```
2. Set the environment variable `ALLOW_READ_ACROSS_TENANT` when call consoel command

    ```bash
    ALLOW_READ_ACROSS_TENANT=1 rails console
    ```
3. Manual change it in console

    ```ruby
    $ rails c
    $ irb(main):001:0> MultiTenantSupport.allow_read_across_tenant
    ```

## Testing
### Minitest (Rails default)

```ruby
# test/test_helper.rb
require 'multi_tenant_support/minitet'
```
### RSpec (with Capybara)

```ruby
# spec/rails_helper.rb or spec/spec_helper.rb
require 'multi_tenant_support/rspec'
```

Above code will make sure the `MultiTenantSupport.current_tenant` won't accidentally be reset during integration and system tests. For example:

With above testing requre code

```ruby
# Integration test
test "a integration test" do
  host! "apple.example.com"

  assert_no_changes "MultiTenantSupport.current_tenant" do
    get users_path
  end
end

# System test
test "a system test" do
  Capybara.app_host = "http://apple.example.com"

  assert_no_changes "MultiTenantSupport.current_tenant" do
    visit users_path
  end
end
```

## Code Example

### Database Schema

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
    config.current_tenant_account_method = :current_tenant_account
  end

  app do |config|
    config.excluded_subdomains = ['www']
    config.host = 'example.com'
  end

  console do |config|
    config.allow_read_across_tenant_by_default = false
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

## ActiveRecord proteced methods

<table>
  <thead>
    <tr>
      <th colspan="8">ActiveRecord proteced methods</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td>count</td>
      <td>🔒</td>
      <td>save</td>
      <td>🔒</td>
      <td>account=</td>
      <td>🔒</td>
      <td>upsert</td>
      <td>⚠️ (Partial)</td>
    </tr>
    <tr>
      <td>first</td>
      <td>🔒</td>
      <td>save!</td>
      <td>🔒</td>
      <td>account_id=</td>
      <td>🔒</td>
      <td>destroy</td>
      <td>🔒</td>
    </tr>
    <tr>
      <td>last</td>
      <td>🔒</td>
      <td>create</td>
      <td>🔒</td>
      <td>update</td>
      <td>🔒</td>
      <td>destroy!</td>
      <td>🔒</td>
    </tr>
    <tr>
      <td>where</td>
      <td>🔒</td>
      <td>create!</td>
      <td>🔒</td>
      <td>update_all</td>
      <td>🔒</td>
      <td>destroy_all</td>
      <td>🔒</td>
    </tr>
    <tr>
      <td>find_by</td>
      <td>🔒</td>
      <td>insert</td>
      <td>🔒</td>
      <td>update_attribute</td>
      <td>🔒</td>
      <td>destroy_by</td>
      <td>🔒</td>
    </tr>
    <tr>
      <td>reload</td>
      <td>🔒</td>
      <td>insert!</td>
      <td>🔒</td>
      <td>update_columns</td>
      <td>🔒</td>
      <td>delete_all</td>
      <td>🔒</td>
    </tr>
    <tr>
      <td>new</td>
      <td>🔒</td>
      <td>insert_all</td>
      <td>🔒</td>
      <td>update_column</td>
      <td>🔒</td>
      <td>delete_by</td>
      <td>🔒</td>
    </tr>
    <tr>
      <td>build</td>
      <td>🔒</td>
      <td>insert_all!</td>
      <td>🔒</td>
      <td>upsert_all</td>
      <td>⚠️ (Partial)</td>
      <td>unscoped</td>
      <td>🔒</td>
    </tr>
  </tbody>
</table>



## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/hoppergee/multi_tenant_support.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
