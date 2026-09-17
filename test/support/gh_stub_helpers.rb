# Shared helpers for tests that exercise scripts under scripts/ against a fake
# gh CLI (see test/fixtures/files/fake_gh_*.sh). The stub logs every call to
# GH_STUB_LOG and serves fixture JSON out of GH_STUB_DIR.
module GhStubHelpers
  def setup_gh_stub(fixture_name)
    @dir = Dir.mktmpdir('gh-stub-test')
    @stub_dir = File.join(@dir, 'stub')
    @gh_log = File.join(@dir, 'gh-calls.log')
    FileUtils.mkdir_p(@stub_dir)
    fake_bin = File.join(@dir, 'bin')
    FileUtils.mkdir_p(fake_bin)
    FileUtils.cp(Rails.root.join("test/fixtures/files/#{fixture_name}"), File.join(fake_bin, 'gh'))
    FileUtils.chmod('+x', File.join(fake_bin, 'gh'))
  end

  def teardown_gh_stub
    FileUtils.remove_entry(@dir) if @dir
  end

  def run_stubbed_script(script, extra_env = {})
    env = {
      'PATH' => "#{@dir}/bin:#{ENV.fetch('PATH', nil)}",
      'REPO' => 'owner/repo',
      'GH_STUB_DIR' => @stub_dir,
      'GH_STUB_LOG' => @gh_log,
      'GH_STUB_PRS' => File.join(@stub_dir, 'prs.json'),
    }.merge(extra_env)
    Open3.capture3(env, '/bin/bash', script.to_s, chdir: @dir)
  end

  def gh_calls
    File.exist?(@gh_log) ? File.read(@gh_log) : ''
  end
end
