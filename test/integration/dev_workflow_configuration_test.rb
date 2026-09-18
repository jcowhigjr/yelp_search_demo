require 'test_helper'

# Pins the local-dev wiring for the Tailwind watcher (issues #3017, #3018):
# bin/dev must use the tailwindcss-ruby binary bundled by tailwindcss-rails -
# the same compiler CI uses via `bin/rails tailwindcss:build` - and pass
# `-w always` so the watcher survives foreman's closed stdin. The npm
# `tailwindcss` package was removed to keep one compiler in play.
class DevWorkflowConfigurationTest < ActiveSupport::TestCase
  PROCFILE = Rails.root.join('Procfile.dev')

  test 'Procfile css watcher uses the gem binary with watch[always]' do
    procfile = PROCFILE.read
    css_line = procfile.lines.detect { |l| l.start_with?('css:') }

    assert css_line, 'Procfile.dev must define a css: process'
    assert_includes css_line, 'bin/rails'
    assert_includes css_line, 'tailwindcss:watch[always]'
    assert_not_includes css_line, 'bun x tailwindcss'
    assert_not_includes css_line, 'assets:clobber'
  end

  test 'npm tailwindcss dependency stays removed (single compiler)' do
    package = JSON.parse(Rails.root.join('package.json').read)
    deps = package.fetch('dependencies', {}).merge(package.fetch('devDependencies', {}))
    tailwind_keys = deps.keys.select { |k| k.include?('tailwind') }

    assert_empty tailwind_keys,
                 "no tailwind npm package may return (#{tailwind_keys.join(', ')}) - " \
                 'the gem binary is the only compiler'
  end
end
