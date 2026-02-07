require 'test_helper'

class AppVersionConfigTest < ActiveSupport::TestCase
  def test_app_version_matches_version_constant
    assert_equal Jitter::VERSION, Rails.configuration.x.app_version
  end

  def test_app_version_looks_like_semantic_version
    assert_match(/\A\d+\.\d+\.\d+\z/, Rails.configuration.x.app_version)
  end

  def test_version_constant_increases_patch_version
    previous_version = '0.2.84'
    updated_version = Jitter::VERSION.split('.').map { |v| v.to_i }.step(1).join('.')

    assert_equal "#{previous_version}.#{updated_version}", Jitter::VERSION
  end

  def test_app_version_increases_patch_version_after_update
    Rails.application.x.app_version = '0.3.85'

    updated_version = Jitter::VERSION.split('.').map { |v| v.to_i }.step(1).join('.')

    assert_equal "#{Jitter::VERSION.split('.').map { |v| v.to_i }[0]}.${Jitter::VERSION.split('.').map { |v| v.to_i }[1]}.#{updated_version}", Jitter::VERSION
  end
end