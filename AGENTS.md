# AGENTS.md

This file defines **project-wide rules for all AI agents** working in this repository (Warp, Codex, Claude, Copilot-style tools, etc.).

For Warp-specific details, see `WARP.md`.
For deep policy and methodology, see `docs/AGENTS.md`.

---

## 1. Core runtime & workflow rules

- **Agents run routine commands autonomously**
  - For common operations (e.g., `git status`, `git add`, `git push`, `mise exec -- ./scripts/...`), agents SHOULD:
    - Run the commands themselves via available tools/CLI.
    - Avoid asking the user to type or copy/paste simple commands.
  - The only exceptions are actions that require:
    - Interactive secrets or credentials the agent cannot access, or
    - Explicit human sign-off for risky/destructive operations (e.g., deleting data).

- **Always sync first**
  - Before doing any work in this repo, run:
    - `lefthook run workflow-status` (preferred) or `./scripts/git-sync.sh`
  - Goal: ensure `develop` is up to date, old merged branches are cleaned up, and you are not working on stale code.
  - **IMPORTANT**: See `docs/agent-coder-workflow.md` for the complete agent workflow with required commands.

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

- **CRITICAL: PR-Issue Alignment Verification**
  - **When to request @claude review** (use judgment - @claude review is expensive):
    - **ALWAYS request for:**
      - Multiple acceptance criteria (2+)
      - Complex changes (10+ files or 300+ lines)
      - Cross-cutting concerns (affects multiple systems)
      - New features or major refactoring
      - Changes to AGENTS.md or core documentation
      - When uncertain about scope alignment
    - **SKIP @claude review for:**
      - Single A/C with simple implementation
      - Small PRs (< 5 files, < 100 lines)
      - First push on straightforward issues
      - Documentation-only changes
      - Obvious bug fixes with clear reproduction
  - **Async workflow** (don't block on @claude):
    1. **Create PR** with clear description linking to issue
    2. **Self-verify alignment** - review your changes against issue A/C
    3. **If complex**: Comment `@claude` to request review
    4. **Continue working** - @claude reviews asynchronously (runs on PR open/update)
    5. **Auto-check after 5 minutes** - run `./scripts/check-pr-status.sh` to see CI and review results
    6. **Address feedback** - if @claude or CI finds issues, fix and push
    7. **Auto re-review** - @claude automatically reviews new pushes
  - **Automated status checking:**
    - After pushing, agents should automatically check PR status after 5 minutes
    - Use: `./scripts/check-pr-status.sh [pr_number]` or auto-detect from current branch
    - Script shows:
      - CI check status (✅ passed, ❌ failed, ⏳ pending)
      - @claude review status and summary
      - Human review status
      - Overall PR readiness
    - **Timing guidance:**
      - CI checks: typically start within 1-2 minutes, complete in 3-5 minutes
      - @claude review: typically completes within 3-5 minutes
      - Check at 5 minutes to catch most results
      - If still pending, check again at 10 minutes
  - **Inspecting preview deployments:**
    - After pushing a PR, a preview app is automatically deployed to Heroku (takes ~3 minutes)
    - **Always inspect the preview app** to verify UI changes work correctly
    - **How to find and open the preview app:**
      ```bash
      # Get the deployment URL using GitHub GraphQL API
      gh api graphql -f query='
      query($owner: String!, $repo: String!, $pr: Int!) {
        repository(owner: $owner, name: $repo) {
          pullRequest(number: $pr) {
            commits(last: 1) {
              nodes {
                commit {
                  deployments(first: 5) {
                    nodes {
                      environment
                      latestStatus {
                        environmentUrl
                        state
                      }
                    }
                  }
                }
              }
            }
          }
        }
      }' -f owner=jcowhigjr -f repo=yelp_search_demo -F pr=<PR_NUMBER> | \
      jq -r '.data.repository.pullRequest.commits.nodes[0].commit.deployments.nodes[] | 
             select(.latestStatus.state == "SUCCESS") | 
             .latestStatus.environmentUrl'
      
      # Example output: https://dorkbob-feature-navbar--kxwwcv.herokuapp.com/
      
      # Open in browser preview tool (remove trailing slash)
      # Use browser_preview tool with the URL
      ```
    - **When to inspect preview apps:**
      - Any UI/UX changes (navbar, forms, styling, etc.)
      - New features with user-facing components
      - Language/i18n changes
      - Responsive design updates
    - **What to verify:**
      - Feature works as expected in browser
      - No console errors
      - Mobile responsive behavior
      - Accessibility (keyboard navigation, screen readers)
      - Cross-browser compatibility if critical
  - **Handling flaky test failures:**
    - If a single system test fails but seems unrelated to your changes:
      1. **Create an issue** to track the failure (use temp file for body):
         ```bash
         # Write issue body to temp file
         cat > /tmp/issue.md << 'EOF'
         ## Test Failure in PR #<number>
         - Failed test: <test name>
         - Job link: <url>
         - Possible flaky test or environmental issue
         EOF
         gh issue create --title "Investigate test failure" --body-file /tmp/issue.md --label bug
         ```
      2. **Re-run the specific failed job** to verify if flaky:
         ```bash
         # Get the failed job ID from check-pr-status.sh output
         gh run rerun <run-id> --job <job-id>
         ```
      3. **Document in issue** if test passes on re-run (confirms flaky)
      4. **Continue with PR** if re-run passes and failure is unrelated to changes
    - **Never use multiline strings in CLI arguments** - always write to temp file first
    - This prevents PTY host hangs in Windsurf/terminal tools
  - **CRITICAL: Temp file pattern for all CLI tools:**
    - **Problem**: Multiline strings in CLI arguments cause PTY host hangs
    - **Solution**: Always write content to temp file, pass file path
    - **Examples for common tools:**
      ```bash
      # ✅ CORRECT - GitHub CLI (supports --body-file)
      cat > /tmp/issue.md << 'EOF'
      ## Issue Title
      - Description line 1
      - Description line 2
      EOF
      gh issue create --title "Title" --body-file /tmp/issue.md --label bug
      gh pr create --title "Title" --body-file /tmp/pr.md
      gh pr comment 123 --body-file /tmp/comment.md
      
      # ✅ CORRECT - Git commit (use -F for file)
      cat > /tmp/commit.txt << 'EOF'
      Commit title
      
      Longer description
      with multiple lines
      EOF
      git commit -F /tmp/commit.txt
      
      # ✅ CORRECT - curl (use @filename or --data-binary)
      cat > /tmp/payload.json << 'EOF'
      {
        "key": "value",
        "nested": {
          "data": "here"
        }
      }
      EOF
      curl -X POST -H "Content-Type: application/json" --data @/tmp/payload.json https://api.example.com
      
      # ✅ CORRECT - Any CLI without file support (use stdin redirect)
      cat > /tmp/input.txt << 'EOF'
      Multiline
      content
      here
      EOF
      some-command < /tmp/input.txt
      
      # ❌ WRONG - Will hang PTY
      gh issue create --title "Title" --body "Line 1
      Line 2
      Line 3"
      
      # ❌ WRONG - Will hang PTY
      git commit -m "Title
      
      Description
      More lines"
      
      # ❌ WRONG - Will hang PTY
      curl -d "multiline
      json
      here"
      ```
    - **When to use temp files:**
      - ANY content with newlines
      - ANY content > 100 characters
      - ANY content with special characters that need escaping
      - When in doubt, use temp file
  - **What @claude verifies** (when requested):
    - PR description references correct issue
    - All acceptance criteria addressed
    - No unrelated changes included
    - Tests cover the acceptance criteria
    - Documentation updated if needed
  - **Why this matters:**
    - Prevents scope creep on complex PRs
    - Catches missing A/C before human review
    - Validates completeness on multi-faceted changes
    - Saves human reviewer time
  - **Agent self-check before requesting @claude:**
    - Does PR description clearly link to issue?
    - Are all A/C from issue addressed?
    - Are there any unrelated changes?
    - Do tests cover the changes?
    - Is this complex enough to warrant @claude review?

- **Use the mise toolchain**
  - Prefix all runtime commands with:
    - `mise exec -- <command>`
  - Prefer named mise tasks over raw commands when they exist, for example:
    - `mise run test` instead of manually invoking the full Rails test suite command
    - `mise run test-system` for system tests
    - `mise run brakeman` for security scans
  - Treat `WARP.md` and `mise.toml` as the source of truth for the authoritative list of mise tasks used by CI and hooks.

- **Never bypass hooks**
  - Do **not** use `--no-verify` with Git.
  - Respect lefthook workflows and scripts; they enforce tests, audits, and PR review loops.

- **Prefer lefthook workflows for Git operations**
  - Example: create a new feature branch using:
    - `lefthook run workflow-new-feature feature/<branch-name>`
  - Use descriptive branch names, typically prefixed with `feature/` (or `bugfix/` when appropriate), for example: `feature/agents-config-docs`.
  - Use helper scripts under `scripts/` (e.g., `sync-branch.sh`, `pr-lifecycle.sh`) instead of bespoke Git flows.

- **Merge conflict prevention (automated)**
  - **Pre-commit hook**: Automatically detects merge conflict markers (`<<<<<<<`, `=======`, `>>>>>>>`) in staged files
  - **Blocks commits** with unresolved conflicts - commit will fail with clear error message
  - **No bypass**: Never use `--no-verify` to skip this check
  - **If hook triggers**: Resolve all conflicts before attempting to commit again

- **Commit size validation (automated)**
  - **Pre-commit hook**: Checks for oversized commits and common screwup patterns
  - **Hard limits (blocks commit):**
    - Max 30 files per commit
    - Max 1000 lines changed per commit
  - **Warnings (allows commit):**
    - 15+ files: Consider splitting
    - 500+ lines: Ensure single logical change
    - Lock files + 20+ other files: Possible dependency update mixed with feature work
    - Debug code patterns: `console.log`, `debugger`, `binding.pry`, `byebug`, `puts "DEBUG"`
  - **Why this matters:**
    - Large commits are hard to review
    - Multiple unrelated changes indicate scope creep
    - Generated files accidentally committed
    - Debug code left in production code
  - **If triggered:**
    - Use `git reset HEAD <file>` to unstage files
    - Use `git add -p` for selective staging
    - Break into multiple focused commits

- **Pre-push merge conflict detection**
  - **CRITICAL**: Before pushing or creating a PR, check for merge conflicts with the target branch
  - **Required workflow before push:**
    1. Fetch latest changes: `git fetch origin`
    2. Check for conflicts: `git merge-base --is-ancestor HEAD origin/develop || git merge --no-commit --no-ff origin/develop`
    3. If merge conflicts detected:
       - Resolve conflicts immediately using i18n-tasks for YAML files
       - Commit the merge resolution (pre-commit hook will verify no markers remain)
       - Then push
    4. If no conflicts: proceed with push
  - **Why this matters:**
    - GitHub will flag merge conflicts on PR creation/update
    - Conflicts block PR merging and require immediate attention
    - Proactive detection saves time and prevents broken PRs
    - Allows agent to fix conflicts autonomously before push
  - **Automated check pattern:**
    ```bash
    # Check if current branch can merge cleanly into develop
    git fetch origin develop
    if ! git merge-tree $(git merge-base HEAD origin/develop) HEAD origin/develop | grep -q "^<<<<<"; then
      echo "✅ No merge conflicts detected"
      git push
    else
      echo "❌ Merge conflicts detected - resolving before push"
      git merge origin/develop
      # Resolve conflicts, test, commit, then push
    fi
    ```

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

- **Command hang prevention**
  - **Timeout strategy (enforced in hooks):**
    - Individual system test: 30s max (Cuprite timeout)
    - Full system test suite: 3 minutes max (180s)
    - Setup scripts: 60s max
    - Database operations: 30s max
    - Network requests in tests: 10s max (configure in test helpers)
    - Pre-push hook total: 5 minutes max (enforced by timeout wrappers)
  - **Before running any command, verify:**
    1. Command doesn't require interactive input (check for `--non-interactive`, `--batch`, `--yes` flags)
    2. Command has reasonable timeout protection (use `timeout 30s command ...`)
    3. Arguments are simple (no multi-line, no complex quoting)
    4. Command produces output (use `--verbose` if available to confirm it's running)
  - **High-risk commands that often hang:**
    - Commands that read from stdin without explicit input
    - Commands with missing required arguments
    - Commands that spawn interactive editors or prompts
    - Commands with malformed YAML/JSON in arguments
  - **If a command hangs:**
    1. Cancel immediately (Ctrl+C) - don't wait to see if it completes
    2. Check command documentation for non-interactive flags
    3. Test command with `--help` first to verify syntax
    4. Use temp files for complex inputs instead of inline arguments
    5. Add explicit timeout wrapper: `timeout 30s command ...`
  - **Safe command patterns:**
    ```bash
    # Good - with timeout and verbose output
    timeout 30s mise exec -- bin/rails db:migrate --verbose
    
    # Good - non-interactive flag
    command --non-interactive --batch
    
    # Good - explicit input via file
    command < input.txt
    
    # Bad - may wait for stdin
    command | grep something
    
    # Bad - complex inline argument
    command --value "$(cat large_file.txt)"
    ```

---

## 5. Internationalization (i18n) and Translation Management

- **CRITICAL: Never use edit tool for YAML files** due to JSON parsing bugs in this workspace
- **Use i18n-tasks gem for all locale file management** - never edit YAML files directly
- **Always stage changes before major locale operations** to prevent data loss

### 5.1. Translation Workflow

1. **Check for missing translations**:
   ```bash
   mise exec -- bin/i18n-tasks missing --locales [locale] --pattern '[pattern]'
   ```

2. **Remove problematic existing keys** (if needed):
   ```bash
   mise exec -- bin/i18n-tasks rm '[key_pattern]'
   ```

3. **Add missing translations with placeholders**:
   ```bash
   mise exec -- bin/i18n-tasks add-missing --locales [locale] --pattern '[pattern]' --value '[placeholder]'
   ```

4. **Install translation dependencies** (if needed):
   ```bash
   bundle add easy_translate
   ```

5. **Use Google Translate** (requires valid API key):
   ```bash
   mise exec -- bin/i18n-tasks translate-missing --locales [locale] --from en --backend google
   ```

6. **Alternative: Manual value updates**:
   ```bash
   mise exec -- bin/i18n-tasks tree-set-value --value '[translation]' --pattern '[key]'
   ```

### 5.2. Known Issues and Workarounds

- **Edit tool JSON parsing bug**: Use i18n-tasks instead of direct YAML editing
- **Bash tool JSON parsing bug**: Ensure proper parameter formatting in tool calls
- **Google Translate API**: May require valid API key configuration in `config/i18n-tasks.yml`
- **Locale loading**: Verify `config/initializers/i18n.rb` includes new locales in `available_locales`
- **Rails caching**: May need `mise run test-prepare` to reload locale configurations

### 5.3. Verification Steps

1. **Check YAML syntax**: `ruby -ryaml -e "YAML.load_file('config/locales/[locale].yml'); puts 'YAML syntax is valid'"`
2. **Verify locale availability**: `mise exec -- bin/rails runner "puts I18n.available_locales.inspect"`
3. **Test translations**: Run affected tests to ensure no missing translation errors

---

## 2. Review-first & delayed feedback behavior

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

## 6. Tool-specific notes

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