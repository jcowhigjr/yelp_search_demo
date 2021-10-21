# Jitter
Jitter is a Ruby on Rails application that allows users to find the highest
ranked coffee shops in any city, utilizing the Yelp Fusion API.

Use the application at https://jitter-coffee.herokuapp.com

## Medium blog about development:
https://medium.com/@seanslaughterthompson/jitter-a-ruby-on-rails-coffee-shop-locator-f14bbb919d7d

## Youtube walkthrough:
https://youtu.be/VLgSinVM5ZQ


## workarounds

updated ruby (.ruby-version and Gemfile)
hid pg gem in Gemfile because it was trying to install locally

<!-- https://stackoverflow.com/questions/67205719/yarn-install-check-files-giving-me-error-output-that-i-dont-understand -->
specified .node-version for nodenv to work around yarn crap with node-sass
nodenv install 15.14.0
https://stackoverflow.com/questions/67205719/yarn-install-check-files-giving-me-error-output-that-i-dont-understand

Edit and use credentials for yelp
https://www.yelp.com/developers/documentation/v3/authentication
bin/rails credentials:edit --environment development
<!-- Rails.application.credentials.yelp[:api_key] -->
https://medium.com/scalereal/managing-encrypted-secrets-credentials-with-rails6-7bb31ca65e02

# Hotwire - Rails
Actually...now switch to using importmaps which works well for the basic hotwire-rails setup.
If more complex javascript comes along I plan to switch to using jsbundling-rails gem and esbuild instead of webpack.
followed instructions from rails-turbo and importmap

 bin/rails importmap:install
 bin/rails hotwire:install
 remove webpacker stuff rm bin/webpack-dev-server config/webpack* app/javascript/pack*
 run system tests and disable the ujs stuff that broke with -> data-turbo="false" or data: { turbo: false }

# Ruby 3.1, Rails 7 and bundle update

Plan is to keep this up to date with the latest version of Ruby Rails and most gems

rbenv local

3.1.0-dev

bundle update

bin/rails update
<!-- https://msp-greg.github.io/rails_master/file.upgrading_ruby_on_rails.html -->
# rails update assumes active storage is in use
rm db/migrate/***create_active_storage_variant_records.active_storage.rb
rm db/migrate/***add_service_name_to_active_storage_blobs.active_storage.rb
bin/setup
bin/rake db:test:prepare
bin/rails test:all

# TODO
# So far only a few things were using ujs so disabling turbo as I see them and then will enable turbo after that.
https://github.com/hotwired/turbo-rails/blob/main/UPGRADING.md
Add something as a turbo frame
https://www.google.com/books/edition/_/mYFGEAAAQBAJ?hl=en&gbpv=1&pg=PT54&dq=html+partial+interactivity+frames

# Testing
  bundle exec guard
  system tests -> https://avdi.codes/rails-6-system-tests-from-top-to-bottom/
  better system tests -> https://evilmartians.com/chronicles/system-of-a-test-setting-up-end-to-end-rails-testing
