require 'test_helper'
require 'json'

class GemfileConfigurationTest < ActiveSupport::TestCase
  GEMFILE = Rails.root.join('Gemfile')
  APP_JSON = Rails.root.join('app.json')

  test 'pg gem must be in the optional postgres group' do
    content = File.read(GEMFILE)
    group_match = content.match(/group\s+:postgres,\s*optional:\s*true\s+do\s*\n((?:.*\n)*?)(?=\s+end)/)

    assert group_match, 'Gemfile must have `group :postgres, optional: true do ... end`'
    assert_includes group_match[1], "gem 'pg'",
                    'pg gem must be declared inside the optional postgres group'
  end

  test 'default bootstrap bundle excludes postgres group' do
    content = File.read(GEMFILE)

    assert_includes content, "group :postgres, optional: true",
                    'postgres group must be optional so default bundle install skips pg'
  end

  test 'app.json declares BUNDLE_WITH=postgres for Review Apps and new apps' do
    app_config = JSON.parse(File.read(APP_JSON))

    assert_equal 'postgres', app_config.dig('env', 'BUNDLE_WITH', 'value'),
                 'app.json must set BUNDLE_WITH=postgres so new/Review Apps include the pg gem'

    assert app_config.dig('env', 'BUNDLE_WITH', 'required'),
           'app.json must mark BUNDLE_WITH as required'
  end
end
