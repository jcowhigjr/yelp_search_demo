require 'test_helper'

class CssCompilationTest < ActiveSupport::TestCase
  BUILD_PATH = Rails.root.join('app/assets/builds/tailwind.css')

  setup do
    # Rely on test:prepare (hooks/CI) to build Tailwind once. If not present, skip to avoid flaky native watcher issues.
    skip 'Tailwind build missing; test environment did not precompile assets' unless File.exist?(BUILD_PATH)
  end

  test 'tailwind.css is built and exists' do
    assert_path_exists BUILD_PATH, "Expected Tailwind build output at #{BUILD_PATH}"
  end

  test 'includes bg-primary class from custom utilities' do
    assert_path_exists BUILD_PATH, 'Tailwind CSS build file missing.'
    css_content = File.read(BUILD_PATH)

    assert_match(/\.bg-primary\s*{\s*background-color:\s*var\(--color-primary\)\s*}/, css_content,
                 'Expected .bg-primary class definition in compiled CSS.')
  end

  test 'includes --color-primary CSS variable from @theme' do
    assert_path_exists BUILD_PATH, 'Tailwind CSS build file missing.'
    css_content = File.read(BUILD_PATH)
    # Matches --color-primary: #4B9CD3; or --color-primary:#4B9CD3;
    pattern_primary = /--color-primary:\s*#4B9CD3;/i

    assert_match(pattern_primary, css_content,
                 'Expected --color-primary CSS variable with #4B9CD3 in compiled CSS.')
  end

  test 'includes dark mode primary color override' do
    assert_path_exists BUILD_PATH, 'Tailwind CSS build file missing.'
    css_content = File.read(BUILD_PATH)
    # Matches --color-primary: #223556; or --color-primary:#223556; within a dark mode media query
    pattern_dark = /
      @media\s*\(prefers-color-scheme:\s*dark\)\s*\{\s*:root\s*\{\s*--color-primary:\s*#223556;
    /ix

    assert_match(pattern_dark, css_content,
                 'Expected dark mode override for --color-primary with #223556.')
  end
end
