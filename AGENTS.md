# AGENTS.md

This file defines **project-wide rules for all AI agents** working in this repository (Warp, Codex, Claude, Copilot-style tools, etc.).

For Warp-specific details, see `WARP.md`.
For explicit risk, approval, and preflight rules, see `GOVERNANCE.md`.
For deep policy and methodology, see `docs/AGENTS.md`.

---

## 0. Governance contract

This repository is self-contained. Do not assume a global AI setup exists.

- Before any meaningful mutation, apply the preflight classification from `GOVERNANCE.md`.
- Surface a governance warning whenever a rule is triggered; do not hide it in internal reasoning.
- Re-run the classification at phase transitions:
  - planning to implementation
  - implementation to verification
  - verification to commit, push, PR, or deploy actions
- Treat these as explicit approval gates:
  - production-impacting changes
  - destructive or irreversible actions
  - non-trivial database or persistent data changes
  - secrets, auth, credentials, or permission changes
  - bypassing existing tests, hooks, or validation
  - scope expansion beyond the stated task or linked issue
- Treat these as explicit completion gates for production-adjacent work:
  - technical verification is complete
  - rollback or feature-flag posture is documented
  - user acceptance is explicitly recorded, or the user explicitly approved proceeding without it
- Never:
  - commit or print secrets
  - use `--no-verify`
  - claim verification ran when it did not
  - present production-adjacent work as complete when it is only technically validated and not yet user accepted

Use these baseline orientation commands before non-trivial work:

```bash
mise exec -- lefthook run workflow-status
mise exec -- git status --short --branch
mise exec -- git log --oneline --decorate --graph -10
mise exec -- bin/rails db:version
```

When governance is triggered in a review, planning note, or automation artifact, include a `## Governance Flags` section listing the rule, trigger reason, and resolution or required approval.

## 0.1 Production Acceptance Gate

For any `production-adjacent` change, agents MUST treat the work as incomplete until all of the following are true:

- the linked issue has explicit acceptance criteria
- verification evidence is recorded
- the rollback path or feature-flag posture is recorded
- the user has accepted the outcome, or has explicitly authorized merge/closure without waiting for acceptance

`Production-adjacent` includes:

- deploy or release automation
- CI/CD workflows that can mutate branches, PRs, environments, or scheduled automation behavior
- feature-flag changes, runtime configuration, or production environment logic
- changes whose success depends on live behavior after merge

When production-adjacent work is technically validated but not yet accepted, agents MUST describe it as:

- `validated-not-accepted`

Agents MUST NOT merge, close the linked issue, or describe the work as complete unless either:

- user acceptance is explicitly recorded, or
- the user explicitly directs the agent to proceed without acceptance

For production-adjacent work, the final summary before merge or close MUST answer:

- what was verified
- what was not verified
- what the rollback or flagging path is
- who accepted the work, or whether the user explicitly overrode that requirement

---

## 1. Core runtime & workflow rules

- **Agents run routine commands autonomously**

  - For common operations (e.g., `git status`, `git add`, `git push`, `mise exec -- ./scripts/...`), agents SHOULD:
    - Run the commands themselves via available tools/CLI.
    - Avoid asking the user to type or copy/paste simple commands.
  - The only exceptions are actions that require:
    - Interactive secrets or credentials the agent cannot access, or
    - Explicit human sign-off for risky/destructive operations (e.g., deleting data).

- **Always validate before committing config changes**

  - Before committing any changes to configuration files (especially lefthook.yml, mise.toml, etc.), run validation commands:
    - `mise exec -- lefthook validate` for lefthook.yml
    - `mise exec -- ruby scripts/validate-mise-toml.sh` for mise.toml
  - NEVER use sed for multi-line YAML edits - use Python YAML parser instead
  - If validation fails, reset to known good state and reapply changes carefully

- **Always sync first**

  - Before doing any work in this repo, run:
    - `lefthook run workflow-status` (preferred) or `./scripts/git-sync.sh`
  - Goal: ensure `develop` is up to date, old merged branches are cleaned up, and you are not working on stale code.
  - **IMPORTANT**: See `docs/agent-coder-workflow.md` for the complete agent workflow with required commands.
  - If hooks or tooling fail, check for upstream fixes by syncing with `develop` before proposing local workarounds.

- **Run a long-session retro before final handoff**

  - Before the final response in a long or blocker-heavy session, agents SHOULD invoke:
    - the `session-retro` skill via the agent platform's skill or tool interface
  - Treat a session as retro-required when any of these are true:
    - runtime exceeds roughly 20 minutes
    - more than 2 blocker classes appear
    - more than 3 fallback or retry pivots occur
    - the user explicitly asks for more autonomy
    - repo work required multiple environment, auth, or tooling escalations
  - The retro runs after implementation/publish work, not before, and may apply only the smallest safe systemic fix.

- **Re-check capabilities after environment changes**

  - If sandbox, auth, or network conditions materially change during a run, re-probe capabilities immediately.
  - Do not keep assuming earlier blockers still apply after permissions or connectivity improve.
  - Prefer `gh` for GitHub writes when `gh auth status` is healthy and MCP write permissions are narrower or failing.

- **Treat worktree and preview failures as routing problems**

  - If a branch is already checked out in another worktree, pivot immediately to a new branch, another worktree, or repo-wide PR mode.
  - If a known preview URL is dead, treat that as deploy-discovery failure and search for the current preview before declaring visual verification blocked.

- **CRITICAL: Confirm Acceptance Criteria & Linked Issue Before Starting Work**

  - **Before any non-trivial changes**, agents MUST:
    1. **Confirm with user** that there are clear Acceptance Criteria (A/C)
    2. **Verify there is a linked GitHub issue** for the work
    3. **Have a clear plan** with each A/C mapped to implementation steps
    4. **Scope confirmation** - ensure the work is within bounds and not "out of scope"
    5. **Assess test coverage** - identify existing tests that may be affected and plan test updates
  - **Non-trivial changes include**:
    - Any work that requires a new Pull Request
    - New system or unit tests
    - Production environment changes
    - New features or systems (like FeatureFlags)
    - Database schema changes
    - Major refactoring
    - Changes to AGENTS.md or other core documentation like CONTRIBUTING.md, SECURITY.md, etc.
  - **Examples of trivial changes** (don't need A/G confirmation):
    - Simple bug fixes with clear reproduction steps
    - Documentation updates
    - Minor styling tweaks
    - Adding missing tests for existing code
  - **If no issue exists**: Create one first before starting implementation
  - **If A/C unclear**: Ask user to define them before proceeding

- **Production-adjacent work requires acceptance and rollback tracking**

  - For production-adjacent work, agents MUST capture in the issue, PR, or final handoff:
    - verification evidence
    - explicit unverified items
    - rollback path or feature-flag posture
    - user acceptance status
  - If user acceptance has not happened yet, agents MUST call the work `validated-not-accepted`.
  - Agents MUST NOT merge or close production-adjacent work without user acceptance unless the user explicitly authorizes that exception in the current session.

- **Use the mise toolchain**

  - Prefix all runtime commands with:
    - `mise exec -- <command>`
  - Prefer named mise tasks over raw commands when they exist, for example:
    - `mise run test` instead of manually invoking the full Rails test suite command
    - `mise run test-system` for system tests
    - `mise run brakeman` for security scans
  - Treat `WARP.md` and `mise.toml` as the source of truth for the authoritative list of mise tasks used by CI and hooks.
  - When running Git commands that trigger hooks, use `mise exec -- git ...` so non-interactive hooks inherit the pinned toolchain.

- **Never bypass hooks**

  - Do **not** use `--no-verify` with Git.
  - Respect lefthook workflows and scripts; they enforce tests, audits, and PR review loops.

- **Prefer lefthook workflows for Git operations**

  - Example: create a new feature branch using:
    - `lefthook run workflow-new-feature feature/<branch-name>`
  - Use descriptive branch names, typically prefixed with `feature/` (or `bugfix/` when appropriate), for example: `feature/agents-config-docs`.
  - Use helper scripts under `scripts/` (e.g., `sync-branch.sh`, `pr-lifecycle.sh`) instead of bespoke Git flows.

- **Terminal command safety & escaping**
  - **CRITICAL**: Be extremely careful with command line arguments to prevent terminal hangs
  - **Never embed complex multi-line content directly in terminal commands** - this causes buffer overruns and hangs
  - **For commands with complex arguments**:
    - Use heredocs (`<<EOF`) or temporary files instead of inline content
    - Break complex commands into separate, simpler steps
    - Avoid deeply nested quotes or escape sequences
  - **Warning signs that indicate escaping issues**:
    - Commands with multiple levels of nested quotes
    - Very long single-line command arguments (>1000 characters)
    - Complex string interpolation with special characters
    - Multi-line content embedded in single command calls
  - **If a terminal command hangs**: Cancel immediately and simplify the approach using separate steps or temporary files.

---

## 2. Branch Protection and Merge Requirements

### Branch Protection Rules (as of Dec 2025)

The `develop` branch has the following protection rules:

1. **Required Status Checks**:

   - `test` check must pass
   - Strict status checks are enabled (must be up to date before merging)

2. **Pull Request Requirements**:

   - At least one approval required
   - Dismiss stale PR approvals when new commits are pushed
   - Code owner approval required when applicable
   - All conversations must be resolved before merging

3. **History Requirements**:

   - Linear history required (no merge commits)
   - No force pushes allowed
   - No branch deletion allowed

4. **Admin Enforcement**:
   - Branch protections apply to administrators
   - No bypassing of branch protections

### Common Merge Issues and Solutions

1. **"Required status check is pending"**:

   - Ensure all required checks have completed successfully
   - The `test` check must complete successfully
   - Check the Actions tab for any failed workflows

2. **"Merging is blocked"**:

   - Ensure all required reviews are completed
   - Make sure all conversations are resolved
   - Check for any merge conflicts that need to be resolved

3. **"Merge commits are not allowed"**:
   - Use "Squash and merge" or "Rebase and merge" instead of "Create a merge commit"
   - Ensure linear history is maintained

### Troubleshooting

If you encounter merge issues:

1. Check the PR's "Checks" tab for failed statuses

2. Review the "Conversation" tab for unresolved discussions

3. Ensure your branch is up to date with the target branch

4. If needed, rebase your branch and force push:

   ```bash
   git fetch origin
   git rebase origin/develop
   git push --force-with-lease
   ```

---

## 3. Review-first & delayed feedback behavior

When working on **any branch that has an open GitHub pull request**, agents MUST treat automated feedback (Codex, Claude, Copilot, human review) as the **highest priority** work.

### 2.1. GitHub MCP review loop (PR-focused)

When a PR exists for the current branch:

1. **Use the GitHub MCP server first** (when available):
   - Call `pull_request_read` with `method: "get_reviews"` to fetch the latest review states (APPROVED, CHANGES_REQUESTED, COMMENT).
   - Call `pull_request_read` with `method: "get_review_comments"` to fetch inline review comments with file path and line.
   - Detect **new** reviews/comments (not previously processed) and summarize them as top-priority tasks.
2. **Track what has been handled**
   - Keep track (in agent memory/state) of which review IDs and review comment IDs have already been addressed.
   - On each new invocation, surface only newly-arrived feedback and update the tracked state after planning fixes.

### 2.2. Repo-specific review loop (`jcowhigjr/yelp_search_demo`)

For this repository specifically:

- Run the review loop script before any other PR-branch work:

  ```bash
./scripts/review-loop.sh
```

- Treat unresolved review threads (Codex, Claude, Copilot, human) as blocking:
  - Read ALL review comments.
  - Propose and implement code changes to address each.
  - Commit and push (respecting hooks).
  - Resolve the review threads via the documented GraphQL / helper scripts.

This behavior matches the Phase 0 "review-first" protocol described in `WARP.md` and expanded in `docs/AGENTS.md`.

### 2.3. Example review-first loop iteration

A single iteration of the review-first loop should look like this:

1. **Check for feedback**
   - Use the GitHub MCP `pull_request_read` tool (`get_reviews` + `get_review_comments`) and `./scripts/review-loop.sh` to detect any new reviews or unresolved threads for the current PR.
2. **Plan fixes**
   - For each new comment, identify the file/line, restate the issue in your own words, and plan the minimal code/doc change needed.
3. **Implement + verify**
   - Make the changes, run relevant tests (and visual checks when needed), and ensure everything passes locally.
4. **Respond and re-check**
   - Push the changes, respond on the PR if appropriate, then re-run the review loop to confirm there is no remaining unresolved feedback before moving on.

---

## 3. Test coverage and non-brittle system tests

Agents MUST assess test coverage before making changes and maintain system tests in a non-brittle state.

- **Pre-change test assessment**

  - **Before implementing any change**, agents MUST:
    1. Identify existing unit tests that may be affected by the change
    2. Identify existing system tests that may be affected by the change
    3. Assess whether new tests are needed to cover the change
    4. Plan test updates alongside implementation changes

- **System test best practices**

  - **Test rendered behavior, not implementation details**:
    - Focus on what users see and interact with in the browser
    - Test DOM elements, user interactions, and accessibility
    - Avoid testing internal helper methods or implementation specifics
  - **Maintain separation of concerns**:
    - System tests should test full-stack behavior through the browser interface
    - Helper methods should be tested in dedicated unit tests (`test/helpers/`)
    - Do not include helper modules in system test classes
  - **Use robust selectors**:
    - Prefer semantic HTML elements and data attributes over CSS classes
    - Use `data-testid` attributes for elements that need specific targeting
    - Avoid brittle selectors that break with minor UI changes
  - **Test what's implemented, not what's planned**:
    - Write tests for current functionality, not future features
    - Use comments or skip tests for functionality not yet implemented
    - Update tests incrementally as features are added

- **Non-brittle test maintenance**
  - **Review test failures for brittleness**: When tests fail, assess if the failure reveals a real bug or test brittleness
  - **Prefer stable assertions**: Use assertions that test behavior rather than exact DOM structure
  - **Handle timing and async operations**: Use proper waiting strategies for dynamic content
  - **Mobile and responsive testing**: Ensure tests work across different viewport sizes
  - **Regular test maintenance**: Update tests when UI changes are intentional, not just to make tests pass

---

## 4. Rails Cuprite System Tests

System tests using Cuprite provide headless browser verification for visual and interactive changes. This section defines how agents should write, run, and maintain Rails system tests.

### 4.1. Scope

**When to write system tests:**

- User-facing features that involve browser interactions (clicks, form submissions, navigation)
- UI components that use Turbo Frames or Turbo Streams for dynamic updates
- Stimulus controller behaviors that manipulate the DOM or respond to user events
- Authentication flows (login, logout, OAuth)
- Features requiring JavaScript execution (geolocation, auto-complete, real-time updates)

**When NOT to write system tests:**

- Pure backend logic (use unit tests for models, services)
- API endpoints without UI (use controller/integration tests)
- Helper methods or view partials in isolation (use unit tests)
- Database queries or ActiveRecord behavior (use model tests)

**System test focus:**

- Test user-visible behavior and interactions
- Verify DOM structure and content as users would see it
- Test accessibility (ARIA labels, keyboard navigation)
- Validate responsive behavior across viewport sizes
- Confirm error states and user feedback messages

### 4.2. Configuration

**Running system tests:**

```bash
# Prepare test database
mise run test-prepare

# Run all system tests (headless)
HEADLESS=true CUPRITE=true APP_HOST=localhost mise exec -- bin/rails test:system

# Run specific system test file
HEADLESS=true CUPRITE=true APP_HOST=localhost mise exec -- bin/rails test test/system/enabled_features_test.rb

# Run with visible browser (for debugging)
HEADLESS=false CUPRITE=true APP_HOST=localhost mise exec -- bin/rails test:system

# Run with screenshots on failure (automatic in CI)
CUPRITE=true APP_HOST=localhost mise exec -- bin/rails test:system
```

**Environment variables:**

- `HEADLESS=true`: Run Chrome in headless mode (required for CI)
- `CUPRITE=true`: Use Cuprite driver instead of Selenium
- `APP_HOST=localhost`: Set host for test server
- `SHOW_TESTS=1`: Show browser window during test execution
- `CUPRITE_JS_ERRORS=true`: Fail tests on JavaScript errors

**Test helpers available:**

- `SystemTestHelpers`: Debugging and screenshot utilities
- `OAuthTestHelper`: OAuth flow mocking
- `LoginHelpers::System`: User authentication helpers
- `SearchTestHelper`: Yelp API stubbing for search features
- `YelpApiHelper`: HTTP request stubbing for external APIs

### 4.3. Testing Turbo Frames

**Turbo Frame best practices:**

- Use `data-turbo-frame` attributes for frame identification
- Test frame navigation without full page reloads
- Verify frame content updates after user actions
- Test frame loading states and error handling

**Example pattern:**

```ruby
test "turbo frame updates coffee shop details without page reload" do
  visit coffeeshop_path(@coffeeshop)

  # Verify initial frame content
  within "turbo-frame#details" do
    assert_text @coffeeshop.name
  end

  # Trigger frame navigation
  within "turbo-frame#details" do
    click_link "Edit Details"
  end

  # Verify frame updated, not full page
  assert_selector "turbo-frame#details form"
  assert_current_path coffeeshop_path(@coffeeshop) # URL unchanged
end
```

**Common Turbo Frame issues:**

- Missing `turbo-frame` wrapper in response
- Frame ID mismatch between trigger and target
- Nested frames without proper `target` attributes
- Form submissions outside frame scope

### 4.4. Testing Stimulus Controllers

**Stimulus testing approach:**

- Test user-visible side effects, not controller internals
- Verify DOM changes after events fire
- Test data attribute bindings and action connections
- Validate controller lifecycle (connect, disconnect)

**Example pattern:**

```ruby
test "geolocation controller populates location field" do
  visit searches_path

  # Stimulus controller should be connected
  assert_selector "[data-controller='geolocation']"

  # Trigger action via data-action
  click_button "Use My Location"

  # Verify controller updated target
  assert_selector "input[name='location'][value]"
  location_value = find("input[name='location']").value
  assert_not_empty location_value
end
```

**Don't test:**

- Controller class methods directly (use JavaScript unit tests)
- Internal state or private methods
- DOM structure details unrelated to behavior

### 4.5. Testing External API Integrations

**Stubbing external HTTP requests:**

- Use WebMock to stub all external HTTP calls
- Define stubs in test `setup` or helper modules
- Match request patterns (URL, method, headers)
- Return realistic response fixtures

**Example pattern:**

```ruby
class CoffeeshopSystemTest < ApplicationSystemTestCase
  setup do
    # Stub is already configured via YelpApiHelper in ApplicationSystemTestCase
    # stub_yelp_api_request is called automatically
  end

  test "displays search results from Yelp API" do
    visit root_path

    fill_in "Location", with: "San Francisco, CA"
    click_button "Search"

    # Verify stubbed response is rendered
    assert_text "Coffee Shops in San Francisco"
    assert_selector ".coffeeshop-card", count: 3
  end
end
```

**Verification:**

- Ensure no real HTTP requests in tests (WebMock will raise error)
- Verify stub coverage with `WebMock.disable_net_connect!`
- Test both success and error response scenarios
- Keep fixtures minimal and focused on test needs

### 4.6. Reliability Rules

**Avoid brittle tests:**

1. **Use semantic selectors:**

   - Prefer: `find("[data-testid='submit-button']")`
   - Avoid: `find(".mt-4.bg-blue-500.rounded")`

2. **Wait for async operations:**

   - Use Capybara's automatic waiting: `assert_text`, `assert_selector`
   - Avoid: `sleep` or manual timeouts
   - For complex timing: `using_wait_time(10) { ... }`

3. **Test user-visible behavior:**

   - Assert what users see: text, buttons, form fields
   - Avoid: testing CSS classes, element counts (unless meaningful)

4. **Handle race conditions:**

   - Wait for page load: `assert_current_path`
   - Wait for Turbo: `assert_no_selector(".turbo-progress-bar")`
   - Wait for content: `assert_text "Expected Content"`

5. **Isolate test data:**

   - Use fixtures or factory methods in `setup`
   - Clean up in `teardown` if needed
   - Avoid shared state between tests

6. **Mobile viewport testing:**
   - Default screen size: 375x667 (mobile)
   - Test responsive behaviors explicitly
   - Use `page.driver.resize` for viewport changes

**Debugging failures:**

```ruby
# In test file, add temporary debugging
save_screenshot # Saves to tmp/screenshots/
save_and_open_screenshot # Opens in browser

# Or use SystemTestHelpers methods
debug_page_state # Prints URL, title, HTML snippet
```

### 4.7. Standard System Test Template

**File location:** `test/system/<feature>_test.rb`

**Template:**

```ruby
require "application_system_test_case"

class FeatureNameTest < ApplicationSystemTestCase
  setup do
    # Create test data
    @user = users(:one) # or User.create!(...)
    @resource = resources(:one)

    # Stub external APIs if needed
    # (YelpApiHelper is already included and stubbed)
  end

  test "user can complete primary workflow" do
    # 1. Setup: Navigate and authenticate if needed
    visit root_path
    # login_as(@user) # if authentication required

    # 2. Act: Perform user actions
    fill_in "Search", with: "coffee"
    click_button "Submit"

    # 3. Assert: Verify expected outcomes
    assert_text "Results for coffee"
    assert_selector "[data-testid='result-item']", count: 3
    assert_current_path search_results_path
  end

  test "handles error states gracefully" do
    # Test sad path
    visit feature_path
    click_button "Submit" # without filling required field

    assert_text "can't be blank"
    assert_selector "input.error"
  end

  test "works with JavaScript interactions" do
    visit feature_path

    # Trigger Stimulus action
    click_button "Toggle Details"

    # Verify DOM update
    assert_selector "[data-testid='details'].expanded"
    assert_text "Additional Information"
  end
end
```

**Key components:**

1. **setup block:** Prepare fixtures, stubs, test data
2. **Descriptive test names:** "user can..." or "handles... gracefully"
3. **AAA pattern:** Arrange (setup), Act (user actions), Assert (outcomes)
4. **One assertion per logical outcome:** Test one behavior per test method
5. **Coverage:** Happy path, error states, edge cases, JavaScript interactions

**Before committing:**

- Run full system test suite: `mise run test-system`
- Verify tests pass in headless mode: `HEADLESS=true ...`
- Check for brittleness: Do tests break with minor CSS changes?
- Ensure no sleep statements or arbitrary timeouts
- Validate external APIs are stubbed (no real HTTP calls)

---

## 5. Empirical verification & cross-model escalation

Agents MUST prefer **empirical verification** over reasoning alone.

- **Treat Heroku and other remote deploy integrations as black boxes unless credentials are available**

  - GitHub state, repository code, PR metadata, review app URLs mentioned in PRs, and the public behavior of deployed apps are observable.
  - Heroku pipeline configuration, branch mapping, release history, config vars, review-app rules, and promotion targets are **not** observable or queryable unless the current run has working Heroku credentials.
  - Do **not** assume that a merged PR is running in production.
  - Do **not** assume that a successful feature-branch app implies production is updated.
  - When deployment ownership is unclear or account access is unavailable, agents MUST treat the deployment layer as untrusted external state and verify behavior empirically from the live app.

- **Use public provenance and live-site checks to answer deployment questions**

  - When asked why production does not match a merged PR or preview app, agents SHOULD answer using evidence from:
    - current live DOM or asset behavior on the public app
    - repository code at the merged branch or commit
    - PR preview references and recorded verification steps
    - any public commit/build provenance exposed by the app itself
  - If the live app lacks a commit SHA, build stamp, or a version or health endpoint that exposes build identity, or any other equivalent provenance marker, agents SHOULD explicitly call out that gap as a deployment observability problem.
  - If production behavior differs from merged code and the remote deploy platform cannot be inspected directly, agents SHOULD classify the root cause as a deployment-layer mismatch, meaning a problem in the deploy system, environment, or routing that makes live behavior diverge from what repository state and CI claim is deployed, unless contradicted by stronger evidence.
  - Example: if a PR that changes the site header is merged and its review app shows the new header, but production still shows the old header after a reported successful deploy, agents SHOULD treat that as a deployment-layer mismatch unless stronger evidence points elsewhere.

- For code changes:
  - Run the appropriate Rails tests via `mise exec -- bin/rails test ...`.
  - Use system tests / headless verification (Cuprite, Puppeteer/Playwright MCP) for non-trivial UI changes.
- For tricky bugs or cross-layer issues:
  - Use the cross-model prompts provided by:
    - `scripts/generate-cross-model-prompt.sh`
    - `scripts/ai-css-review.sh`
  - Escalate to tools like `claude-cli` only **after** an empirical attempt has been made and captured.

See `docs/AGENTS.md` for the full hypothesis-driven development methodology (Issue #981) and the headless visual verification policy (Issue #982).

---

## 6. JavaScript Minimization Policy

**Principle**: Eliminate JavaScript from CI/CD pipelines and prefer Ruby-native tooling.

### 6.1 CI/CD JavaScript Elimination

**Agents MUST NOT:**

- Add Node.js setup steps to GitHub Actions workflows
- Include yarn/npm install commands in CI/CD
- Use JavaScript-based linting or formatting in hooks
- Require JavaScript dependencies for Rails asset compilation

**Agents MUST:**

- Use Propshaft for asset serving (Rails default)
- Use importmap-rails for JavaScript dependency management
- Use tailwindcss-rails gem for CSS compilation
- Prefer Ruby gems over npm packages for tooling

### 6.2 Local Development JavaScript

**JavaScript tools allowed ONLY for local development:**

- Bun for package management (faster than Yarn)
- ESLint/Prettier for code formatting
- Puppeteer for E2E testing
- Tailwind CSS compilation (via Ruby gem preferred)

**Local setup only:**

- JavaScript dependencies belong in mise.toml for local development
- Never include JavaScript setup in CI/CD workflows
- Use conditional logic: `if [[ "$CI" != "true" ]]; then ...`

### 6.3 Asset Management Strategy

**Use Rails-native stack:**

- **Propshaft**: Asset serving and fingerprinting
- **Importmap**: JavaScript dependency management (no bundler needed)
- **Tailwind CSS**: Via tailwindcss-rails gem
- **Hotwire**: Interactive features without heavy JS frameworks

**Avoid:**

- webpack, vite, or other JavaScript bundlers
- Node.js build steps in CI/CD
- npm scripts for asset compilation
- JavaScript-based CSS preprocessors

### 6.4 Migration Guidelines

**When migrating from JavaScript to Ruby-native tools:**

1. Remove Node.js from GitHub Actions first
2. Update lefthook hooks to use Ruby tools
3. Replace JavaScript linting with RuboCop/Ruby-based tools
4. Use Propshaft instead of webpack for assets
5. Test CI/CD pipeline after each removal

**Acceptance Criteria:**

- CI/CD builds without Node.js installation
- All tests pass without JavaScript tooling
- Build times reduced by 50%+
- Docker images smaller and simpler

---

## 7. Tool-specific notes

### Warp (warp.dev)

- Warp agents should:
  - Treat this `AGENTS.md` as the cross-agent rules file.
  - Use `WARP.md` for Warp-specific runtime commands, git workflows, and PR completion protocols.
  - Consult `docs/AGENTS.md` when deeper policy or examples are needed.

### Codex / GitHub-based agents

- Codex and other tools that look for `AGENTS.md` at the repo root should:
  - Obey the review-first rules above.
  - Prefer GitHub MCP + `./scripts/review-loop.sh` for discovering delayed reviews on PRs.

### Claude / claude-cli

- Claude-specific configuration is in `CLAUDE.md`.
- For local workflows (e.g., `claude-cli`):
  - Use the prompts generated by `scripts/generate-cross-model-prompt.sh` and `scripts/ai-css-review.sh`.
  - Follow the empirical verification and escalation guidelines from `docs/AGENTS.md`.

---

## 7. Source-of-truth hierarchy

In case of conflict or ambiguity:

1. **Project rules:** This `AGENTS.md` file (cross-agent contract).
2. **Warp-specific details:** `WARP.md`.
3. **Deep policy & methodology:** `docs/AGENTS.md`.

Agents should resolve discrepancies by:

- Favoring more recent, explicit guidance.
- Avoiding changes that would violate the review-first protocol or empirical verification requirements.
