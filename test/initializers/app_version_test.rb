require 'test_helper'

class AppVersionConfigTest < ActiveSupport::TestCase
  def test_app_version_matches_version_constant
    assert_equal Jitter::VERSION, Rails.configuration.x.app_version
  end

  def test_app_version_looks_like_semantic_version
    assert_match(/\A\d+\.\d+\.\d+\z/, Rails.configuration.x.app_version)
  end
end
