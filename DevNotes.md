# My Dev Notes

TLDR:
 Using GitHub PRs for feature changes and bugfixes
 Using Github Actions see main.yml for CI/CD workflow
 Using Heroku for hosting
 Using Yelp for fusion API
 Using Google for sign in.


Below are some other notes in order of the things I've changed.
# get it working from where I picked it up on a Mac
updated ruby (.ruby-version and Gemfile)

hid pg gem in Gemfile because it was trying to install locally

(a single user doesn't need PG for this kind of dev but run bin/setup if sqlite ever locks)
<!-- https://stackoverflow.com/questions/67205719/yarn-install-check-files-giving-me-error-output-that-i-dont-understand -->

(currently only using node for linting)
specified .node-version for nodenv to work around yarn crap with node-sass
nodenv install 15.14.0
https://stackoverflow.com/questions/67205719/yarn-install-check-files-giving-me-error-output-that-i-dont-understand

Edit and use credentials for yelp
https://www.yelp.com/developers/documentation/v3/authentication
bin/rails credentials:edit --environment development

<!-- Rails.application.credentials.yelp[:api_key] -->

https://medium.com/scalereal/managing-encrypted-secrets-credentials-with-rails6-7bb31ca65e02

# Yelp

https://github.com/Yelp/yelp-ruby/tree/develop/spec
https://www.yelp.com/developers/documentation/v3/business

# Add Hotwire - Rails

Actually...now switch to using importmaps which works well for the basic hotwire-rails setup.
If more complex javascript comes along I plan to switch to using jsbundling-rails gem and esbuild instead of webpack.
followed instructions from rails-turbo and importmap

bin/rails importmap:install
bin/rails hotwire:install
remove webpacker stuff rm bin/webpack-dev-server config/webpack* app/javascript/pack*
run system tests and disable the ujs stuff that broke with -> data-turbo="false" or data: { turbo: false }

# Upgrade to Ruby 3.1, Rails 7 and bundle update

Plan is to keep this up to date with the latest version of Ruby Rails and most gems

<!-- https://eregon.me/blog/2021/06/04/review-of-ruby-installers-and-switchers.html -->  brew upgrade rbenv ruby-build

rbenv local

3.1.0-dev

bundle update

bin/rails update

<!-- https://msp-greg.github.io/rails_master/file.upgrading_ruby_on_rails.html -->

# rails update assumes active storage is in use

rm db/migrate/**_create_active_storage_variant_records.active_storage.rb
rm db/migrate/_**add_service_name_to_active_storage_blobs.active_storage.rb
bin/setup
bin/rake db:test:prepare
bin/rails test:all

# TODO

# So far only a few things were using ujs so disabling turbo as I see them and then will enable turbo after that.(turbo is currently in use in most places now)

https://github.com/hotwired/turbo-rails/blob/main/UPGRADING.md
Add something as a turbo frame
https://www.google.com/books/edition/_/mYFGEAAAQBAJ?hl=en&gbpv=1&pg=PT54&dq=html+partial+interactivity+frames

# Development

 git flow feature start xyz-feature

 `be guard`  # run tests and linting, asset processing/live reload connection to browser while developing in the background
 `bin/dev`   # run dev server and css processor

 commit
  see lefthook.yml

 open a PR
 `gh pr create`

# System Tests
system tests -> https://avdi.codes/rails-6-system-tests-from-top-to-bottom/

these are run by default on commit with a iphone 6/7/8 screen size to test mobile navigation
be guard while developing

To debug system tests:
add 'focus' just above the test
SHOW_TESTS=true MAGIC_TEST=true be guard

better system tests -> https://evilmartians.com/chronicles/system-of-a-test-setting-up-end-to-end-rails-testing
Insert 'magic_test' in system tests to BDD style improve the app.
[evil systems](https://github.com/ParamagicDev/evil_systems)

# Sign in with Google

https://console.cloud.google.com/apis/credentials?project=coffeeshop-325618
see client_id and client_secret in rails credentials:edit --development
git ignore config/master.key and kep in a safe place
git add development key is probably safe

# Propshaft assets https://github.com/rails/propshaft/issues/36#issuecomment-982933727

One thing you should be careful is that if you run rails assets:precompile in your computer and then ./bin/dev Propshaft will use the static resolver, not the dynamic one. And since the static resolver reads files from public/assets, any change you make to your source files in app/assets will not take an effect when you reload the page.

To solve that, run rails assets:clobber. It will remove all files from public/assets and force Propshaft back to the dynamic resolver.

#LiveReload for css changes and importmaps
https://www.colby.so/posts/live-reloading-with-esbuild-and-rails

# FontAwesome

bin/importmap pin fontawesome
Pinning "fontawesome" to https://ga.jspm.io/npm:fontawesome@5.6.3/index.js

# https://guillaumebriday.fr/introducing-stimulus-components

#importmaps
https://github.com/hotwired/stimulus-rails/pull/24

https://guillaumebriday.fr/introducing-stimulus-components

# Github

github actions will run CI including a rails tests on a PR to develop see .github/workflows/main.yml

# Deployment

heroku pipelines will deploy a preview instance on a PR that has passed CI
-> BUNDLE_WITHOUT='development:test' BUNDLE_PATH=vendor/bundle BUNDLE_BIN=vendor/bundle/bin BUNDLE_DEPLOYMENT=1 bundle install -j4

# Environment variables

RAILS_ENV test/development/production are the only ones set externally

# Secrets

An environment variable stored in github and heroku RAILS\_**ENVIRONMENT**\_KEY
is used to decrypt those secretes stored in encrypted credential files for the api's used

# if there were more going on i'd never rebase but there isn't
roughly using git flow but integration branch is develop, prod release branch is master (no prod though really)

# two feature branches going at once
# if one gets merged first (typically a squash commit)

# stage anything that seems promising
git add {files}
# stash files that aren't yet ready
git stash push --keep-index
# pull develop locally
git co develop
git pull
# find the feature branch again
# alias gb='git for-each-ref --sort=committerdate refs/heads/ --format='\''%(committerdate:short) %(refname:short)'\'' | tail -n20'
gb
#co the feature branch
git co feature/xyz
# pull in the changes
git flow feature rebase
git stash apply
