source "https://rubygems.org"
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby ENV['RUBY_VERSION'] || '~> 3.1.0'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
# gem 'rails', github: 'rails/rails', branch: '7-0-stable'
gem 'rails', '~> 7.0.1'

# The original asset pipeline for Rails [https://github.com/rails/sprockets-rails]
# gem "sprockets-rails"
gem "propshaft"

<<<<<<< HEAD
gem 'puma', '~> 4.1'
# Use SCSS for stylesheets
gem 'sass-rails'
# Transpile app-like JavaScript. Read more: https://github.com/rails/webpacker
# gem 'webpacker'
# Turbolinks makes navigating your web application faster. Read more: https://github.com/turbolinks/turbolinks
gem 'turbo-rails'
gem 'importmap-rails'
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder'
# Use Redis adapter to run Action Cable in production
gem 'redis', '~> 4.0'
# Use Active Model has_secure_password
gem 'bcrypt'

# Use Active Storage variant
# gem 'image_processing', '~> 1.2'

# Reduces boot times through caching; required in config/boot.rb
gem 'bootsnap', '>= 1.4.2', require: false
=======
>>>>>>> dockerize
# gem 'omniauth-google-oauth2', github: 'zquestz/omniauth-google-oauth2', branch: 'master'
gem 'omniauth-google-oauth2'

gem 'omniauth-rails_csrf_protection'

gem 'json'
gem 'rest-client'
# Use the Puma web server [https://github.com/puma/puma]
gem "puma", "~> 5.0"

# Use JavaScript with ESM import maps [https://github.com/rails/importmap-rails]
gem "importmap-rails"

# Use Redis adapter to run Action Cable in production
# gem "redis", "~> 4.0"

# Use Kredis to get higher-level data types in Redis [https://github.com/rails/kredis]
# gem "kredis"

platforms :ruby do
  gem 'sqlite3', require: false if /postgres/.match?(ENV['DB']) || ENV['DB_ALL']
  if ENV['DB_ALL'] || !/mysql|postgres/.match?(ENV['DB'])
    gem 'fast_sqlite', require: false
    gem 'sqlite3', require: false
    gem 'pg', require: false
  end
end
# Use Active Model has_secure_password [https://guides.rubyonrails.org/active_model_basics.html#securepassword]
gem "bcrypt", "~> 3.1.7"

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem "tzinfo-data", platforms: %i[ mingw mswin x64_mingw jruby ]

# Reduces boot times through caching; required in config/boot.rb
gem "bootsnap", require: false

# Use Sass to process CSS
# gem "sassc-rails"

gem 'hotwire-rails' # , '~> 0.1.3'
# Use Active Storage variants [https://guides.rubyonrails.org/active_storage_overview.html#transforming-images]
# gem "image_processing", "~> 1.2"

group :development, :test do
  # See https://guides.rubyonrails.org/debugging_rails_applications.html#debugging-with-the-debug-gem
  gem "debug", platforms: %i[ mri mingw x64_mingw ]
  gem 'meta_request', github: 'jcowhigjr/rails_panel', branch: 'jcowhigjr-support-rails-7.0'

end


group :development do
  # Use console on exceptions pages [https://github.com/rails/web-console]
  gem "web-console"

  # Add speed badges [https://github.com/MiniProfiler/rack-mini-profiler]
  # gem "rack-mini-profiler"

  # Speed up commands on slow machines / big apps [https://github.com/rails/spring]
  # gem "spring"

  gem 'guard' # , '~> 2.18'
  gem 'guard-minitest' # , '~> 2.4'
end

group :test do
  # Adds support for Capybara system testing and selenium driver
  gem 'capybara' # , '~> 3.35'
  gem 'selenium-webdriver' # , '~> 4.0'
  # Easy installation and use of web drivers to run system tests with browsers
  gem 'matrix'
  gem 'webdrivers'
  # gem 'minitest-colorize'
  gem 'minitest-focus'
  gem 'magic_test'
  gem 'cuprite'
  gem 'evil_systems'
end
