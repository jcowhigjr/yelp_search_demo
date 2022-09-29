source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby ENV.fetch('RUBY_VERSION', '~> 3.1.2')

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
# gem 'rails', github: 'rails/rails', branch: '7-0-stable'
gem 'rails', '~> 7.0.4'

# The original asset pipeline for Rails [https://github.com/rails/sprockets-rails]
# gem "sprockets-rails"
gem 'propshaft'

# gem 'omniauth-google-oauth2', github: 'zquestz/omniauth-google-oauth2', branch: ' '
gem 'omniauth-google-oauth2'

gem 'omniauth-rails_csrf_protection'

gem 'json'
gem 'rest-client'
# Use the Puma web server [https://github.com/puma/puma]
gem 'puma', '~> 5.6'

# Use JavaScript with ESM import maps [https://github.com/rails/importmap-rails]
gem 'importmap-rails'

# Use Redis adapter to run Action Cable in production
# gem "redis", "~> 4.0"

# Use Kredis to get higher-level data types in Redis [https://github.com/rails/kredis]
# gem "kredis"

platforms :ruby do
  gem 'pg', require: false

  if ENV.fetch('DB_ALL', nil) || !/mysql|postgres/.match?(ENV.fetch('DB', nil))
    gem 'fast_sqlite', require: false, group: :test
    gem 'sqlite3', require: false, group: :development
  end
end
# Use Active Model has_secure_password [https://guides.rubyonrails.org/active_model_basics.html#securepassword]
gem 'bcrypt', '~> 3.1.7'

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: %i[mingw mswin x64_mingw jruby]

# Reduces boot times through caching; required in config/boot.rb
gem 'bootsnap', require: false

# Use Sass to process CSS
# gem "sassc-rails"

gem 'hotwire-rails'

gem 'turbo-rails', '~> 1.1.0'

# Use Active Storage variants [https://guides.rubyonrails.org/active_storage_overview.html#transforming-images]
# gem "image_processing", "~> 1.2"

gem 'brotli'
gem 'rack-brotli'
gem 'sprockets-exporters_pack'
# gem 'smart_assets', group: :production
# gem 'heroku-deflater', git: 'https://github.com/pungerfreak/heroku-deflater.git'


group :development, :test do
  # See https://guides.rubyonrails.org/debugging_rails_applications.html#debugging-with-the-debug-gem
  gem 'debug', platforms: %i[mri mingw x64_mingw]
  gem 'meta_request',
      github: 'jcowhigjr/rails_panel',
      branch: 'jcowhigjr-support-rails-7.0'
end

group :development do
  # Use console on exceptions pages [https://github.com/rails/web-console]
  gem 'web-console'

  # Add speed badges [https://github.com/MiniProfiler/rack-mini-profiler]
  # gem "rack-mini-profiler"

  # Speed up commands on slow machines / big apps [https://github.com/rails/spring]
  # gem "spring"

  gem 'guard' # , '~> 2.18'
  gem 'guard-minitest' # , '~> 2.4'
  gem 'guard-rubocop' # , '~> 2.4'

  # https://dev.to/zilton7/installing-livereload-on-rails-6-5blj
  gem 'guard-livereload', require: false # , '~> 2.4'
  gem 'rack-livereload'

  # foreman required to start bin/dev
  gem 'foreman', require: false
  gem 'rubocop', require: false
  gem 'rubocop-minitest', require: false
  gem 'rubocop-rails', require: false
  gem 'rubocop-performance', require: false
  gem 'prettier', require: false
  gem 'erb_lint', require: false
  gem 'brakeman', require: false
  # gem 'solargraph', require: false
  # gem 'solargraph-rails', require: false

  # if you don't use brew bundle to install with the Brewfile, you can install it with:
  # gem 'lefthook', require: false
  gem 'better_html', require: false

  gem 'i18n-tasks', require: false
  gem 'easy_translate', require: false
end

group :test do
  # Adds support for Capybara system testing and selenium driver
  gem 'capybara' # , '~> 3.35'
  gem 'selenium-webdriver' # , '~> 4.0'

  # Easy installation and use of web drivers to run system tests with browsers
  gem 'matrix'
  gem 'webdrivers'

  # gem 'minitest-colorize'
  gem 'cuprite'
  gem 'evil_systems'
  gem 'magic_test'
  gem 'minitest-focus'
  gem 'minitest-retry'
end

gem 'tailwindcss-rails', '~> 2.0'

# gem 'flipper-active_record'
gem 'flipper', require: 'flipper/adapters/pstore'

gem 'dotenv-rails'
