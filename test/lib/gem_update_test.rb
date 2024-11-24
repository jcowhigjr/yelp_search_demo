# test/lib/gem_update_test.rb
require 'minitest/autorun'
require 'mocha/minitest'  # Add this line
require_relative '../../lib/gem_update'

class TestGemUpdate < Minitest::Test
  def setup
    @diff_fixture = File.read(File.join(__dir__, '../fixtures/gemfile_lock_diff_fixture.txt'))
  end

  def test_extract_gem_diff
    result = extract_gem_diff(@diff_fixture)

    assert_equal 'lefthook', result[:gem_name]
    assert_equal '1.7.17', result[:gem_version]
  end

  def test_extract_gem_diff_no_bump
    diff = <<~DIFF
      -    example_gem (1.2.3)
    DIFF

    result = extract_gem_diff(diff)

    assert_nil result[:gem_name]
    assert_nil result[:gem_version]
  end

  def test_update_gem
    gem_name = 'lefthook'
    gem_version = '1.7.17'
    gemfile = 'Gemfile.next'

    
    Kernel.expects(:system).with("BUNDLE_GEMFILE=#{gemfile} bundle update #{gem_name}").returns(true)  # Stubbing with Mocha

    assert update_gem(gem_name, gem_version, gemfile)
  end

  def test_update_gem_no_bump
    assert_output("No gem version bump detected.\n") do
      update_gem(nil, nil, 'Gemfile.next')
    end
  end
end
