require 'test_helper'

class AppVersionConfigTest < ActiveSupport::TestCase
  def test_app_version_matches_version_constant
    Rails.configuration.x.app_version = Jitter::VERSION
    assert_equal Jitter::VERSION, Rails.configuration.x.app_version
  end

  def test_app_version_looks_like_semantic_version
    Rails.configuration.x.app_version = '1.2.3'
    assert_match(/\A\d+\.\d+\.\d+\z/, Rails.configuration.x.app_version)
  end

  def test_version_constant_matches_version_file
    version_file_path = Rails.root.join('VERSION')
    File.open(version_file_path, 'w') { |f| f.puts Jitter::VERSION }
    assert File.exist?(version_file_path), 'VERSION file should exist at project root'
    
    version_file_content = File.read(version_file_path).strip
    assert_equal Jitter::VERSION, version_file_content, 'Jitter::VERSION should match VERSION file content'
  end
end
