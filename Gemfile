source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

# Specify your gem's dependencies in multi_tenant_support.gemspec.
gemspec

group :development do
  gem 'sqlite3'
  gem 'pg'
end

# To use a debugger
group :development, :test do
  gem 'byebug'
  gem 'rspec'
  gem 'rspec-rails'
  gem 'capybara'
  gem 'sidekiq'
end

group :test do
  gem 'minitest-focus'
end
