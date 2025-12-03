# DorkBob needs a name

A pretty generic Ruby on Rails 8 application that allows users to find anything near them by topic, utilizing the Yelp Fusion API.

Use the application at https://dorkbob.herokuapp.com

## 🤖 For AI Agents / Agent Coders

**IMPORTANT**: This project uses automated git workflow protection. Before making any changes, please read:
- [`docs/agent-coder-workflow.md`](docs/agent-coder-workflow.md) - **Required reading for AI agents**
- Use `lefthook run workflow-status` and `lefthook run workflow-new-feature <branch>` instead of direct git operations
- Before pushing, regenerate the production Tailwind bundle with `scripts/verify-tailwind-build.sh` (or let the `tailwind-build-check` pre-push step run) to confirm dark-mode utilities exist in `app/assets/builds/tailwind.css`.
- When touching UI styles, run `bin/dev` and validate the rendered page with the built-in Puppeteer tooling (or Windsurf browser preview). Capture a quick search result screenshot to confirm dark cards look correct in dark mode.

### Visual verification workflow

We now ship a lightweight Puppeteer script to capture deterministic screenshots for any route you specify. Run it via mise/yarn so agents get the right environment:

```bash
mise exec -- yarn visual:verify --urls "/,/search?query=coffee,/favorites"
```

Key flags/environment variables:

| Option | Env Var | Default | Description |
| --- | --- | --- | --- |
| `--base-url` | `VISUAL_VERIFY_BASE_URL` | `http://localhost:3000` | Root app URL (use staging/prod for remote checks). |
| `--urls` | `VISUAL_VERIFY_URLS` | `/` | Comma-separated route list to capture. |
| `--out-dir` | `VISUAL_VERIFY_OUTPUT_DIR` | `tmp/visual-verification` | Output directory for PNGs. |
| `--width/--height` | `VISUAL_VERIFY_WIDTH/HEIGHT` | `1280x720` | Viewport size. |
| `--wait-ms` | `VISUAL_VERIFY_WAIT_MS` | `500` | Extra delay after page load before snapshotting. |
| `--full-page` | `VISUAL_VERIFY_FULL_PAGE` | `true` | Capture full scroll height when `true`. |

Use this before shipping any non-trivial visual change so reviewers can diff the generated screenshots (they land in `tmp/visual-verification`).

## Motivation:

I was looking for a project to practice on when i had spare time.

## For Devs ->

### Getting Started

**Prerequisites:**

*   **mise:** This project uses `mise` to manage tool versions. Please install it from [https://mise.run](https://mise.run) if you haven't already.

**Setup:**

The main setup instruction is to run the `bin/setup` script:

```bash
bin/setup
```

This script will:
1.  Ensure `mise` is installed and configured for the project.
2.  Use `mise` to install the correct versions of Ruby, Node.js, Yarn, and Lefthook as defined in the `mise.toml` file.
3.  Install all necessary Ruby gem dependencies.
4.  Install Node.js package dependencies.
5.  Set up the database.
6.  Set up Git hooks using Lefthook.

**⚠️ Important: API Configuration Required**

After setup, you'll need to configure the Yelp API key for the application to work properly. See [API_SETUP.md](API_SETUP.md) for detailed instructions.

**Environment and Automated Checks:**

This project leverages `mise` for consistent tool versioning and `Lefthook` for managing Git hooks and automated checks (e.g., tests, linters) defined in `lefthook.yml`.

*   **Mise Activation:** For interactive shells, `mise` is typically activated via `eval "$(mise activate zsh)"` (or your shell equivalent) in your shell's rc file (e.g., `~/.zshrc`). For non-interactive sessions or to make shims available with minimal overhead, `eval "$(mise activate zsh --shims)"` can be used in a profile script (e.g., `~/.zprofile`). The `bin/setup` script helps guide this.
*   **Running Commands in Hooks:** To ensure that commands within `Lefthook` hooks (and other scripts) execute with the correct tool versions and environment variables defined by `mise`, they are prefixed with `mise exec --`. For example, a test command in `lefthook.yml` might look like `mise exec -- bundle exec rails test`. This is crucial for the reliability of automated checks.

### Common Development Tasks

This project uses `mise` to manage and run common development tasks. You can list available tasks with `mise tasks` or `mise ls`. Here are some key examples:

*   `mise run setup`: Re-run the initial development setup process.
*   `mise run test`: Run all unit and integration tests.
*   `mise run test-system`: Run system tests (e.g., browser-based tests).
*   `mise run lint`: Run all configured linters (e.g., RuboCop for Ruby, Prettier for JavaScript).
*   `mise run fix`: Attempt to automatically fix issues found by linters.
*   `mise run brakeman`: Run the Brakeman security scanner.

System and other Rails tests honor the `RAILS_TEST_WORKERS` environment variable to control parallelization (default: 3 workers). For example:

```bash
RAILS_TEST_WORKERS=3 HEADLESS=true CUPRITE=true APP_HOST=localhost mise exec -- bin/rails test:system
```

**E2E Language Tests:** The project includes Puppeteer-based end-to-end tests for language switching functionality. See [`test/e2e/README.md`](test/e2e/README.md) for details.

```bash
# Run language switcher tests (requires Rails server running)
yarn test:e2e:language
```

For more detailed development notes, see [DevNotes.md](DevNotes.md). Additional resources can be found in [Resources.md](Resources.md).

## Attribution

Sean was kind enough to let me share it with potential employers.

Sean's blog and source code:

https://medium.com/@seanslaughterthompson/jitter-a-ruby-on-rails-coffee-shop-locator-f14bbb919d7d

Jitter totally vibed with me because my favorite place to code has been in coffeeshops, and I was like I will enjoy myself at a coffeeshop working on a coffeeshop app.

## Changes/Rebranding:

One day, without research 🧐, I decided I wanted to help find tacos and directions to a yoga studio so then i switched it up.

Old school good enough features:

Search for something near you.
Decide quickly with the 'Decision Wheel'

Reuse the app day to day for favorite spots.

Click telephone 📞 and call a human to order take out.
Click 🧭 for directions to open in your phone to get there.

Not sure about a place .. link out to yelp for more features.

Future Opportunities?
Remove unused features:
seperate user rating? (this is not allowed by the yelp agreement anyway)
Extend used features:
pictures -- pull in more with click
user submitted photos .. hmm ActiveStorage could handle this.

Add a business plan:

Yelpish:
Filter the favorites based on your location.

Social:
Share with friends?
Live Poll for where to go.

Personal: Keep a tally of the places you've been.

Community:
Specialize and white label by search term .. eg) coffee.dorkbob.com
Or make it local by neighborhood or club. eg) taco-club.dorkbob.com
# Updated git config to remove nano editor
