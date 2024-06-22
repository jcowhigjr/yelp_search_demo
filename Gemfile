def next?
  File.basename(__FILE__) == 'Gemfile.next'
end

source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

# ruby File.read('.ruby-version').strip

# I want dependabot to update ruby to the latest patch version and set it in the Gemfile.lock
# I think this will allow different machines to run tests with different ruby patch versions

if next?
  if File.exist?('.ruby-version-next')
    ruby File.read('.ruby-version-next').strip
  end
else
  ruby File.read('.ruby-version').strip
end

ruby ENV.fetch('RUBY_VERSION', File.read('.ruby-version').strip )

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
# gem 'rails', github: 'rails/rails', branch: '7-0-stable'
gem 'next_rails'

if next?
  gem 'rails', '>= 7.1.3'
else
  gem 'rails', '~> 7.1.3'
end



# The original asset pipeline for Rails [https://github.com/rails/sprockets-rails]
# gem "sprockets-rails"
gem 'propshaft'

gem 'omniauth-google-oauth2'

gem 'omniauth-rails_csrf_protection'

gem 'json'
gem 'rest-client'
# Use the Puma web server [https://github.com/puma/puma]
gem 'puma', '~> 6.4'

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
gem 'bcrypt', '~> 3.1.20'

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: %i[mingw mswin x64_mingw jruby]

# Reduces boot times through caching; required in config/boot.rb
gem 'bootsnap', require: false

# Use Sass to process CSS
# gem "sassc-rails"

gem 'hotwire-rails'

gem 'turbo-rails', '~> 2.0.5'

# Use Active Storage variants [https://guides.rubyonrails.org/active_storage_overview.html#transforming-images]
# gem "image_processing", "~> 1.2"

gem 'brotli'
gem 'rack-brotli'
gem 'sprockets-exporters_pack'
# gem 'smart_assets', group: :production
# gem 'heroku-deflater', git: 'https://github.com/pungerfreak/heroku-deflater.git'


group :development, :test do
  # See https://guides.rubyonrails.org/debugging_rails_applications.html#debugging-with-the-debug-gem

  gem 'meta_request'
end

group :development do
  # Use console on exceptions pages [https://github.com/rails/web-console]
  gem 'web-console'

  # Add speed badges [https://github.com/MiniProfiler/rack-mini-profiler]
  # gem "rack-mini-profiler"

  # Speed up commands on slow machines / big apps [https://github.com/rails/spring]
  # gem "spring"

  gem 'guard'
  gem 'guard-minitest'
  gem 'guard-rubocop'

  # https://dev.to/zilton7/installing-livereload-on-rails-6-5blj
  gem 'guard-livereload', require: false # , '~> 2.4'
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
  gem 'brakeman', require: false
  # gem 'solargraph', require: false
  # gem 'solargraph-rails', require: false

  # if you don't use brew bundle to install with the Brewfile, you can install it with:
  gem 'lefthook', require: false
  gem 'bundler-audit', require: false
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

  # gem 'minitest-colorize'
  gem 'cuprite'
  gem 'evil_systems'
  gem 'magic_test'
  gem 'minitest-focus'
  gem 'minitest-retry'
end

gem 'tailwindcss-rails', '~> 2.6'

# gem 'flipper-active_record'
gem 'flipper'

gem 'dotenv'
