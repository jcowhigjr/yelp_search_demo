def next?
  File.basename(__FILE__) == 'Gemfile.next'
end

source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

# ruby File.read('.ruby-version').strip

# I want dependabot to update ruby to the latest patch version and set it in the Gemfile.lock
# I think this will allow different machines to run tests with different ruby patch versions

# ruby File.read('.ruby-version').strip

gem 'bundler', '~> 2.5'

# Pin minitest to 5.x due to incompatibility with Rails 8.1.1
# See issue #1337 for details
gem 'minitest', '~> 6.0'

# Bundle edge Rails instead: gem 'rails', "~> 8.0"
# gem 'rails', "~> 8.0"
# `next_rails` 1.4.7 currently hard-requires `byebug`, which breaks this repo's
# CI boot path because the app uses the `debug` gem instead. Keep the last known
# good version pinned until compatibility is verified.
gem 'next_rails', '1.5.0'

gem 'rails', '>= 8.1.0.beta1', '< 8.2'

# The original asset pipeline for Rails [https://github.com/rails/sprockets-rails]
# gem "sprockets-rails"
gem 'propshaft'

gem 'omniauth-google-oauth2'

gem 'omniauth-rails_csrf_protection'

gem 'json'
gem 'rest-client'
# Use the Puma web server [https://github.com/puma/puma]
gem 'puma', '~> 7.2'

# Use JavaScript with ESM import maps [https://github.com/rails/importmap-rails]
gem 'importmap-rails'

# Use Redis adapter to run Action Cable in production
# gem "redis", "~> 4.0"

# Use Kredis to get higher-level data types in Redis [https://github.com/rails/kredis]
# gem "kredis"

platforms :ruby do
  gem 'pg', require: false

  if ENV.fetch('DB_ALL', nil) || !/mysql|postgres/.match?(ENV.fetch('DB', nil))
    gem 'sqlite3', '~> 2.9', require: false, group: :development
  end
end
# Use Active Model has_secure_password [https://guides.rubyonrails.org/active_model_basics.html#securepassword]
gem 'bcrypt', '~> 3.1.22'

# Reduces boot times through caching; required in config/boot.rb
gem 'bootsnap', require: false

# Use Sass to process CSS
# gem "sassc-rails"

gem 'hotwire-rails'

gem 'turbo-rails', '~> 2.0'

# Use Active Storage variants [https://guides.rubyonrails.org/active_storage_overview.html#transforming-images]
# gem "image_processing", "~> 1.2"

gem 'brotli'
gem 'rack-brotli'
gem 'sprockets-exporters_pack'
# gem 'smart_assets', group: :production
# gem 'heroku-deflater', git: 'https://github.com/pungerfreak/heroku-deflater.git'


group :development, :test do
  # See https://guides.rubyonrails.org/debugging_rails_applications.html#debugging-with-the-debug-gem
  gem 'debug'
  gem 'brakeman', require: false
end

group :development do
  # Use console on exceptions pages [https://github.com/rails/web-console]
  gem 'web-console'

  unless next?
    gem 'meta_request'
  end
  # Add speed badges [https://github.com/MiniProfiler/rack-mini-profiler]
  # gem "rack-mini-profiler"

  # Speed up commands on slow machines / big apps [https://github.com/rails/spring]
  # gem "spring"

  gem 'guard'
  gem 'guard-minitest'
  gem 'guard-rubocop'

  # https://dev.to/zilton7/installing-livereload-on-rails-6-5blj
  gem 'rack-livereload'

  # foreman required to start bin/dev
  gem 'foreman', require: false
  gem 'rubocop', require: false
  gem 'rubocop-minitest', require: false
  gem 'rubocop-rails', require: false
  gem 'rubocop-performance', require: false
  gem 'rubocop-capybara', require: false
  gem 'prettier', require: false
  gem 'erb_lint', require: false
  gem 'yaml-lint', require: false
  # gem 'solargraph', require: false
  # gem 'solargraph-rails', require: false

  # if you don't use brew bundle to install with the Brewfile, you can install it with:
  gem 'bundler-audit', require: false
  gem 'better_html', require: false

  gem 'i18n-tasks', require: false
end

# group :development, :ci already defined below

group :test do
  gem 'webmock', require: false
  gem 'mocha', require: false # For mocking and stubbing in tests
  # Adds support for Capybara system testing and selenium driver
  gem 'capybara' # , '~> 3.35'
  gem 'selenium-webdriver' # , '~> 4.0'

  # Easy installation and use of web drivers to run system tests with browsers
  gem 'matrix'

  # gem 'minitest-colorize'
  gem 'cuprite'
  gem 'evil_systems'
  gem 'magic_test'
  # gem 'minitest-focus'
  # gem 'minitest-retry'
end

gem 'tailwindcss-rails', '~> 4.4'

gem 'flipper'

gem 'dotenv'

gem 'geocoder'

# Removed duplicated development, ci group

# Ruby version (must match mise.toml)
ruby '3.3.10'
