require 'test_helper'

require 'fileutils'
require 'json'
require 'open3'
require 'tmpdir'

# Executable smoke coverage for scripts/daily-repo-health-findings.sh.
# The fake gh validates --jq usage the same way the real CLI does: extra
# positional arguments after the expression are an error. That misuse is what
# made the workflow fail daily before the issue #3003 repair.
class DailyRepoHealthFindingsTest < ActiveSupport::TestCase
  include GhStubHelpers

  SCRIPT = Rails.root.join('scripts/daily-repo-health-findings.sh')

  def setup
    setup_gh_stub('fake_gh_daily_health.sh')
  end

  def teardown
    teardown_gh_stub
  end

  test 'healthy repository stays silent and exits successfully' do
    write_stub_json('prs', [])
    write_stub_json('prs_dependabot', [])
    write_stub_json('smoke', [run_json('success', 'https://x/1')])
    write_stub_json('ci', [run_json('success', 'https://x/2')])

    stdout, stderr, status = run_findings

    assert_predicate status, :success?, stderr
    assert_empty stdout
    assert_includes gh_calls, 'pr list'
    assert_includes gh_calls, 'run list'
  end

  test 'reports stranded dependabot smoke and CI findings together' do
    write_stub_json('prs', [
      { 'number' => 42, 'title' => 'queued and behind', 'mergeStateStatus' => 'BEHIND',
        'autoMergeRequest' => { 'enabledAt' => 'x' } },
      { 'number' => 43, 'title' => 'clean without queue', 'mergeStateStatus' => 'CLEAN',
        'autoMergeRequest' => nil },
    ])
    write_stub_json('prs_dependabot', [
      { 'number' => 99, 'title' => 'bump rails', 'createdAt' => '2020-01-01T00:00:00Z' },
      { 'number' => 100, 'title' => 'fresh bump', 'createdAt' => Time.now.utc.strftime('%Y-%m-%dT%H:%M:%SZ') },
    ])
    write_stub_json('smoke', [run_json('failure', 'https://x/smoke')])
    write_stub_json('ci', [run_json('failure', 'https://x/ci')])

    stdout, stderr, status = run_findings

    assert_predicate status, :success?, stderr
    assert_includes stdout, '### Stranded auto-merge PRs (queued but BEHIND develop)'
    assert_includes stdout, '- #42 queued and behind'
    assert_not_includes stdout, '#43'
    assert_includes stdout, '### Dependabot PRs open more than 24h'
    assert_includes stdout, '- #99 bump rails'
    assert_not_includes stdout, '#100'
    assert_includes stdout, '### Production Smoke Check failing on develop'
    assert_includes stdout, '### Rails CI (main.yml) failing on develop'
  end

  test 'script never passes unsupported arguments to gh --jq' do
    assert_not_includes File.read(SCRIPT), '--jq'
  end

  private

  def run_json(conclusion, url)
    { 'conclusion' => conclusion, 'url' => url, 'createdAt' => '2026-09-15T01:00:00Z' }
  end

  def run_findings
    run_stubbed_script(SCRIPT)
  end

  def write_stub_json(name, payload)
    File.write(File.join(@stub_dir, "#{name}.json"), JSON.generate(payload))
  end
end
