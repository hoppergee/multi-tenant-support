source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

# Specify your gem's dependencies in multi_tenant_support.gemspec.
gemspec

group :development do
  gem 'sqlite3'
  gem 'pg'
end

# To use a debugger
gem 'byebug', group: [:development, :test]
group :test do
  gem 'minitest-focus'
  gem 'sidekiq'
  gem 'capybara'
  gem 'rspec'
  gem 'rspec-rails'
end
