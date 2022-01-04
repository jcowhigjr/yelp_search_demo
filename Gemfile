source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '~> 3'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
# gem 'rails'
gem 'rails', github: 'rails/rails', branch: '7-0-stable'
# gem "rails"
# , ">= 7.0.0.rc1",  github: 'rails/rails', branch: '7-0-stable'
# Use sqlite3 as the database for Active Record
# gem 'propshaft'
gem 'puma', '~> 4.1'
# Use SCSS for stylesheets
# gem 'sass-rails'

# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder'
# Use Redis adapter to run Action Cable in production
gem 'redis', '~> 4.0'
# Use Active Model has_secure_password
gem 'bcrypt'

# Use Active Storage variant
# gem 'image_processing', '~> 1.2'

# Reduces boot times through caching; required in config/boot.rb
gem 'bootsnap', require: false # , '~> 1.9.1', require: false
# gem 'omniauth-google-oauth2', github: 'zquestz/omniauth-google-oauth2', branch: 'master'
gem 'omniauth-google-oauth2'
gem 'omniauth-rails_csrf_protection'

# gem 'dotenv-rails'
gem 'json'
gem 'rest-client'
group :development, :test do
  # gem 'rack-mini-profiler'
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  # gem 'debug', platforms: [:mri, :mingw, :x64_mingw]
  gem 'debug', '~> 1.0'

  # bugem 'web-console', '~> 4.1'
end

group :development do
  gem 'foreman' # needed for bin/dev

  # Use console on exceptions pages [https://github.com/rails/web-console]
  gem "web-console", ">= 4.1.0"
  gem "brakeman"
  # Add speed badges [https://github.com/MiniProfiler/rack-mini-profiler]
  # gem "rack-mini-profiler", ">= 2.3.3"
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
  gem 'net-pop'
  gem 'net-imap'
end

# ruby 3.1.0dev
# You have already activated digest 3.0.1.pre, but your Gemfile requires digest 3.0.0. Since digest is a default gem, you can either remove your dependency on it or try updating to a newer version of bundler that supports digest as a default gem. (Gem::LoadError)
gem 'digest', '~> 3.1.0pre2'

gem 'net-smtp'


platforms :ruby do
  gem 'sqlite3', '~> 0.5', require: false if /mysql/.match?(ENV['DB']) || ENV['DB_ALL']
  gem 'sqlite3', '~> 1.0', require: false if /postgres/.match?(ENV['DB']) || ENV['DB_ALL']
  if ENV['DB_ALL'] || !/mysql|postgres/.match?(ENV['DB'])
    gem 'fast_sqlite', require: false
    gem 'sqlite3', require: false
  end
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: %i[mingw mswin x64_mingw jruby]

# gem 'meta_request', '>= 0.7.3'
gem 'meta_request', github: 'jcowhigjr/rails_panel', branch: 'jcowhigjr-support-rails-7.0'
# , glob: 'meta_request/meta_request.gemspec'

#  To use the asset pipeline version of hotwire or turbo, you must have importmap-rails installed first and listed higher in the Gemfile.
gem 'importmap-rails' # , '~> 0.6.1'
gem 'propshaft'

gem 'hotwire-rails' # , '~> 0.1.3'

gem 'guard-minitest' # , '~> 2.4'

gem 'guard' # , '~> 2.18'

# rspotify is a gem for the Spotify Web API (https://developer.spotify.com/web-api/).
#TODO: gem 'rspotify' should be upgraded
# when public suffix and rest client are bumped in this gem
gem 'rspotify', '>= 2.1'
