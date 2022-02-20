source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

if rails_version = ENV['RAILS_VERSION']
  gem 'rails', rails_version
end

# Specify your gem's dependencies in multi_tenant_support.gemspec.
gemspec

group :development do
  gem 'sqlite3'
  gem 'pg'
end

# To use a debugger
group :development, :test do
  gem 'matrixeval-ruby'
  gem 'byebug'
  gem 'rspec'
  gem 'rspec-rails'
  gem 'capybara'
  gem 'sidekiq'

  # Ruby 3.1 split out the net-smtp gem
  # Necessary until https://github.com/mikel/mail/pull/1439
  # got merged and released.
  if Gem.ruby_version >= Gem::Version.new("3.1.0")
    gem "net-smtp", "~> 0.3.0", require: false
  end
end

group :test do
  gem 'minitest-focus'
end
