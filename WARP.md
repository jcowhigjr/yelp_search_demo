# WARP.md

This file provides guidance to WARP (warp.dev) when working with code in this repository.

Project: Rails 8 app ("Jitter") for location-based search using Yelp Fusion. Tooling is centered on mise, lefthook, and Rails' native stack (importmap, propshaft, tailwindcss-rails, Hotwire). System tests use Cuprite.

## 🤖 CRITICAL FOR AI AGENTS

**ALWAYS run this FIRST before starting any work:**
```bash
./scripts/git-sync.sh
```

This ensures:
- Your local develop branch is synced with GitHub
- Old merged branches are cleaned up
- You're working with the latest code
- No conflicts from stale local state

**Then create your feature branch:**
```bash
lefthook run workflow-new-feature feature/<branch-name>
```

The sync also runs automatically when creating branches, but run it explicitly at conversation start.

## 🔄 PR COMPLETION PROTOCOL

**When working on an existing PR, ALWAYS follow this autonomous completion loop:**

### Phase 0: Review-First Loop (HIGHEST PRIORITY)

**GitHub branch protection treats _any_ unresolved review thread (human, Codex, Claude, etc.) as "needs approval" and keeps `mergeStateStatus=BLOCKED` until every thread is resolved.**

**Check for reviews BEFORE any other action:**
```bash
./scripts/review-loop.sh
```

If unresolved reviews exist:
1. Read ALL review comments
2. Fix each issue in code
3. Commit and push (pre-push hooks validate automatically)
4. Reply to each comment documenting the fix
5. Resolve each thread via GitHub GraphQL API:
   ```bash
   gh api graphql -f query='mutation { resolveReviewThread(input: {threadId: "THREAD_ID"}) { thread { id isResolved } } }'
   ```
   - Convenience helpers:
     - `scripts/resolve-thread.sh <THREAD_ID>`
     - `scripts/resolve-all-threads.sh [--force]`
6. **LOOP BACK** - Check for reviews again (Step 1)

**Critical**: Never wait for user to say "address feedback" - fix immediately and autonomously.

Codex runs automatically when you open/ready a PR or comment `@codex review`; Claude runs on `@claude` / `@claude-suggest`. Both produce standard review threads and must be resolved exactly like human feedback.

Use `lefthook run workflow-review-loop` at any time for the structured review check (same output as the script above). Pre-push hooks now run this automatically and block pushes while reviews remain.

### Complete PR Workflow

Once all reviews are addressed:

```bash
# Check overall PR completion status
./scripts/pr-completion-check.sh --auto-merge
```

This validates:
- ✅ Phase 0: All review threads resolved
- ✅ Phase 1-2: CI checks passing
- ✅ Phase 3: Approval requirements met
- ✅ Phase 4: Branch up-to-date, no conflicts
- ✅ Phase 5: Ready to merge

### Merge Execution

When all phases complete:

```bash
# If approvals are pending (will merge when approved)
gh pr merge --auto --squash

# If self-approval blocked and changes are uncontroversial
gh pr merge --admin --squash
```

### Key Principles

1. **Review-first always** - Check for reviews before any other PR action
2. **Fix immediately** - Don't wait for prompts; address feedback autonomously
3. **Resolve explicitly** - Use GraphQL API to mark threads resolved
4. **Loop automatically** - Keep checking until no reviews remain
5. **Push immediately** - Pre-push hooks validate; don't wait for remote CI
6. **Complete to merge** - Goal is merged PR, not just "ready for review"

### Documentation

- **Full workflow**: [docs/pr-completion-workflow.md](./docs/pr-completion-workflow.md)
- **Review loop details**: [docs/review-first-autopilot.md](./docs/review-first-autopilot.md)
- **Helper scripts**: `./scripts/review-loop.sh`, `./scripts/pr-completion-check.sh`

## General Rules
- Always prefix runtime commands with: mise exec --
- Never bypass git hooks with --no-verify
- Prefer lefthook workflow commands to raw git for branch/PR operations

1) Common commands
- Setup
  - mise exec -- bin/setup
  - mise exec -- bin/setup --skip-server
- Run app (Procfile.dev)
  - mise exec -- bin/dev
- Tests
  - Prepare DB: mise run test-prepare
  - All tests: mise exec -- bin/rails test
  - Single file: mise exec -- bin/rails test test/controllers/searches_controller_test.rb
  - Single test: mise exec -- bin/rails test test/models/coffeeshop_test.rb:15
  - System tests (Cuprite): HEADLESS=true CUPRITE=true APP_HOST=localhost mise exec -- bin/rails test:system
  - Tasks: mise run test, mise run test-system
- Lint/format
  - Ruby: mise exec -- bundle exec rubocop
  - ERB: mise exec -- bundle exec erblint --lint-all
  - Prettier check: mise exec -- yarn prettier --check 'app/**/*.{js,jsx,ts,tsx,css,scss,json}'
  - Prettier write: mise exec -- yarn prettier --write 'app/**/*.{js,jsx,ts,tsx,css,scss,json}'
  - Auto-fix set: lefthook run fixer
- Security/audits
  - Brakeman: mise run brakeman
  - Gems: mise exec -- bundle audit update && mise exec -- bundle audit check
  - Importmap audit: mise exec -- bin/importmap audit
- Git workflow (lefthook)
  - Status: lefthook run workflow-status
  - New feature branch: lefthook run workflow-new-feature <branch-name>
- Branch/PR helpers (scripts)
  - Sync with base: ./scripts/sync-branch.sh [main|develop]
  - PR lifecycle: ./scripts/pr-lifecycle.sh [trigger|poll|sync] [...]
- Tailwind CSS v4
  - Dev watch (from Procfile.dev): css process runs via yarn tailwindcss --watch
  - Validate setup: make tailwind_enforce_config
- Docker (optional)
  - docker-compose up -d
  - docker-compose down

2) High-level architecture and structure
- Domain and data
  - Models: app/models/{search.rb, coffeeshop.rb, review.rb, user.rb, user_favorite.rb}
  - DB: db/migrate/* and db/schema.rb define Users, Reviews, Coffeeshops, UserFavorites, Searches; seeds in db/seeds.rb
  - Associations:
    - User has many Reviews and Favorites
    - Coffeeshop has many Reviews
    - UserFavorite joins User and Coffeeshop
    - Search records query + optional lat/lng
- Web/API surface
  - Routes (config/routes.rb) are locale-scoped: scope '(:locale)' across the app; root to searches#new
  - Key resources: searches (new/create/show/update), coffeeshops (show with nested reviews new/create/index), reviews (index/edit/update/destroy), user_favorites & favorites (create/destroy), sessions (login/logout), users (new/show/create)
  - Health endpoint: GET /healthz
- Controllers
  - SearchesController orchestrates location/topic queries (entry point page)
  - CoffeeshopsController shows a venue; ReviewsController manages reviews
  - SessionsController handles email/password and Google OAuth2 (omniauth)
  - Favorites/UserFavorites toggle and list favorites
- Frontend stack
  - Importmap + Stimulus controllers in app/javascript/controllers (e.g., geolocation_controller.js) for UI behaviors
  - Hotwire (turbo-rails) for reactive UI
  - Propshaft for assets; tailwindcss-rails (v4) for CSS pipeline; Procfile.dev spawns web and css processes
- Configuration
  - config/application.rb sets Rails 8 defaults and development iframe headers; includes lib/jitter/railtie
  - config/initializers/custom_configuration.rb: default_url_options (prod), compression middlewares Rack::Deflater + Rack::Brotli, i18n locales [:en, :es, :fr, :'pt-BR']
  - Feature flags via flipper initializer
  - Omniauth initializer for Google OAuth2
- Testing
  - Minitest with helpers under test/support/**/*; WebMock enables HTTP stubbing
  - System tests use Capybara + Cuprite with EvilSystems helpers (test/application_system_test_case.rb)
  - Cuprite is the default JS driver; screenshots/inspection via Cuprite (respect project rule: use Cuprite for capturing)
  - Common helpers: SystemTestHelpers, OAuthTestHelper, YelpApiHelper; stub YELP API in setup

3) Repo conventions and workflows
- Tooling via mise (mise.toml)
  - Ruby 3.4.4 pinned; tasks define test/test-system/brakeman flows; several env defaults disable pagers
  - Always execute with mise exec -- to match CI and hooks environment
- Git enforcement via lefthook (lefthook.yml, .lefthook.yml)
  - Protects main/develop from direct commits
  - Pre-commit runs branch sync checks and linters; pre-push runs full Rails tests and audits (see lefthook.yml)
  - Never bypass hooks; prefer lefthook run workflow-* utilities to manage branches
- Scripts (scripts/*.sh)
  - sync-branch.sh: detects ahead/behind/diverged and auto-merges base (uses mise exec -- for merges/pushes)
  - pr-lifecycle.sh: trigger/poll/sync PRs with verification and coding standards checks
- Procfiles
  - Procfile.dev: web (bin/rails server) + css (yarn tailwindcss watcher)
  - Procfile.test: guard flow for test:prepare and headless system runs

4) Focused usage examples
- Create and work on a new feature branch
  - lefthook run workflow-new-feature feature/my-change
  - Implement changes; commit/push normally (hooks will run)
- Quickly run a single test
  - mise exec -- bin/rails test test/models/user_test.rb:42
- Reproduce CI locally (pre-push set)
  - lefthook run pre-push
- Run system tests headless with Cuprite
  - HEADLESS=true CUPRITE=true APP_HOST=localhost mise exec -- bin/rails test:system
- Validate Tailwind configuration
  - make tailwind_enforce_config

5) Pointers to in-repo docs
- README.md: project overview, agent-coder notices, and Puppeteer-based visual verification workflow
- docs/git-workflow.md: lefthook-centric git process and protections
- docs/pr-workflow.md: PR lifecycle, sample configurations, troubleshooting, and how to use prompts (including headless visual verification)
- docs/intelligent-ci-cd.md: Dependabot-aware CI test selection strategy
- docs/AGENTS.md: agent policies including empirical verification (Issue #981) and headless browser verification for visual changes (Issue #982)
- scripts/README.md: details for sync-branch.sh and pr-lifecycle.sh

Notes
- For non-trivial visual/UI changes, prefer headless browser verification (Puppeteer MCP or Playwright) per Issue #982, and/or the Rails Cuprite system test prompt under `.github/prompts/`.
- Secrets: never commit or echo secrets. If a command requires credentials, ensure they are sourced into environment variables by the user prior to execution.
- Network/API: Tests stub external calls (WebMock); run real API calls only in development with proper environment.

