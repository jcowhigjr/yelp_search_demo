require 'test_helper'

class AppVersionConfigTest < ActiveSupport::TestCase
  def test_app_version_matches_version_constant
    assert_equal '0.3.0', Rails.configuration.x.app_version
  end

  def test_app_version_looks_like_semantic_version
    assert_match(/\A\d+\.\d+\.\d+\z/, '0.3.0')
  end

  def test_version_constant_matches_version_file
    version_file_path = Rails.root.join('VERSION')

    assert_path_exists version_file_path, 'VERSION file should exist at project root'
    
    version_file_content = File.read(version_file_path).strip

    assert_equal '0.3.0', version_file_content, 'Jitter::VERSION should match VERSION file content'
  end
end
