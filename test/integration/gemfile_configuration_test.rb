require 'test_helper'

class GemfileConfigurationTest < ActiveSupport::TestCase
  GEMFILE = Rails.root.join('Gemfile')

  test 'pg gem must be in the default group without platform restrictions' do
    lines = File.readlines(GEMFILE).map(&:chomp)
    pg_line_idx = lines.index { |l| l.match?(/^\s*gem ['"]pg['"]/) }

    assert pg_line_idx, 'pg gem declaration not found in Gemfile'

    pg_line = lines[pg_line_idx]

    assert_not pg_line.match?(/^  /),
               "pg gem appears to be indented (#{pg_line.strip}), meaning it's inside a block. " \
               'It must be at the top level of the Gemfile to avoid Bundler 2.7.1 deployment-mode issues on Heroku.'
  end
end
