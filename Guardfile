# frozen_string_literal: true

# A sample Guardfile
# More info at https://github.com/guard/guard#readme

## Uncomment and set this to only include directories you want to watch
directories %w[app lib config test]

## Note: if you are using the `directories` clause above and you are not
## watching the project directory ('.'), then you will want to move
## the Guardfile to a watched dir and symlink it back, e.g.
#
#  $ mkdir config
#  $ mv Guardfile config/
#  $ ln -s config/Guardfile .
#
# and, you'll have to watch "config/Guardfile" instead of "Guardfile"

# ENV['MAGIC_TEST'] ||= 'true'
# ENV['SHOW_TESTS'] ||= 'true'

# Set environment variables for system tests
ENV['APP_HOST'] ||= '127.0.0.1'
ENV['CUPRITE'] ||= 'true'
ENV['HEADLESS'] ||= 'true'
ENV['RAILS_ENV'] ||= 'test'
ENV['CUPRITE_JS_ERRORS'] ||= 'true'

guard :rubocop, all_after_pass: false, all_on_start: false, focus_failed: false do
  watch(/.+\.rb$/)
  watch(%r{(?:.+/)?\.rubocop(?:_todo)?\.yml$}) { |m| File.dirname(m[0]) }
end

guard :minitest,
      spring: 'bin/rails test',
      all_after_pass: false,
      all_on_start: false,
      focus_failed: false,
      retry_failed: false do
  # with Minitest::Unit
  watch(%r{^test/(.*)/?(.*)_test\.rb$})
  watch(%r{^lib/(.*/)?([^/]+)\.rb$})     { |m| "test/#{m[1]}test_#{m[2]}.rb" }
  watch(%r{^test/test_helper\.rb$})       { 'test' }

  # Rails files
  watch(%r{^app/(.+)\.rb$})                               { |m| "test/#{m[1]}_test.rb" }
  watch(%r{^app/controllers/application_controller\.rb$})  { 'test/controllers' }
  watch(%r{^app/controllers/(.+)_controller\.rb$})        { |m| "test/integration/#{m[1]}_test.rb" }
  watch(%r{^app/views/(.+)_mailer/.+})                    { |m| "test/mailers/#{m[1]}_mailer_test.rb" }
end
