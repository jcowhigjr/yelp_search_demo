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
Switch to using webpack:

bundle add jsbundling-rails
bundle update
./bin/rails javascript:install:webpack

now: Switch to using webpack and startup with
foreman start -f Procfile.dev
