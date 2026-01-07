require 'test_helper'

class AppVersionConfigTest < ActiveSupport::TestCase
  def test_app_version_matches_version_constant
    assert_equal Jitter::VERSION, Rails.configuration.x.app_version
  end

  def test_app_version_looks_like_semantic_version
    assert_match(/\A\d+\.\d+\.\d+\z/, Rails.configuration.x.app_version)
  end

  def test_version_constant_matches_version_file
    version_file_path = Rails.root.join('VERSION')
    assert File.exist?(version_file_path), 'VERSION file should exist at project root'
    
    version_file_content = File.read(version_file_path).strip
    assert_equal Jitter::VERSION, version_file_content, 'Jitter::VERSION should match VERSION file content'
  end

  def test_app_version_is_increased_by_one_patch
    previous_version = '0.2.28'.freeze
    Rails.configuration.x.app_version = previous_version
    
    assert_equal '0.2.29', Rails.configuration.x.app_version, 'app_version is updated correctly'

    old_value = Jitter::VERSION
    Rails.configuration.x.app_version = old_value

    assert_equal '0.2.29', Jitter::VERSION, "Jitter::VERSION is updated correctly"

  end
end
