# Fixture helpers for the fake-gh files used by AutoUpdatePrsTest: prs.json is
# the `gh pr list` payload, head-<N> is the current head SHA for PR N, and
# seq-<N> is the mergeStateStatus sequence returned by successive `gh pr view`.
module AutoUpdateStubHelpers
  AUTO_MERGE = { 'enabledAt' => 'x' }.freeze
  FAST_BOUNDS = {
    'AUTO_UPDATE_RECHECK_ATTEMPTS' => '3',
    'AUTO_UPDATE_RECHECK_DELAY_SECONDS' => '0',
    'AUTO_UPDATE_HEAD_WAIT_ATTEMPTS' => '5',
    'AUTO_UPDATE_HEAD_WAIT_DELAY_SECONDS' => '0',
  }.freeze

  def pr(number:, state:, **fields)
    {
      'number' => number,
      'isCrossRepository' => false,
      'headRefName' => "branch-#{number}",
      'headRefOid' => "sha-#{number}",
      'mergeStateStatus' => state,
      'autoMergeRequest' => nil,
    }.merge(fields)
  end

  def prs(payload)
    File.write(File.join(@stub_dir, 'prs.json'), JSON.generate(payload))
  end

  def write_head(number, sha)
    File.write(File.join(@stub_dir, "head-#{number}"), sha)
  end

  def write_state_sequence(number, states)
    File.write(File.join(@stub_dir, "seq-#{number}"), "#{states.join("\n")}\n")
  end

  def run_script(script, extra_env = {})
    run_stubbed_script(script, FAST_BOUNDS.merge(extra_env))
  end
end
