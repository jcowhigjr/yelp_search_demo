# DorkBob needs a name

A pretty generic Ruby on Rails 8 application that allows users to find anything near them by topic, utilizing the Yelp Fusion API.

Use the application at https://dorkbob.herokuapp.com

## 🤖 For AI Agents / Agent Coders

**IMPORTANT**: This project uses automated git workflow protection. Before making any changes, please read:
- [`docs/agent-coder-workflow.md`](docs/agent-coder-workflow.md) - **Required reading for AI agents**
- Use `lefthook run workflow-status` and `lefthook run workflow-new-feature <branch>` instead of direct git operations

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

**Environment and Automated Checks:**

This project leverages `mise` for consistent tool versioning and `Lefthook` for managing Git hooks and automated checks (e.g., tests, linters) defined in `lefthook.yml`.

*   **Mise Activation:** For interactive shells, `mise` is typically activated via `eval "$(mise activate zsh)"` (or your shell equivalent) in your shell's rc file (e.g., `~/.zshrc`). For non-interactive sessions or to make shims available with minimal overhead, `eval "$(mise activate zsh --shims)"` can be used in a profile script (e.g., `~/.zprofile`). The `bin/setup` script helps guide this.
*   **Running Commands in Hooks:** To ensure that commands within `Lefthook` hooks (and other scripts) execute with the correct tool versions and environment variables defined by `mise`, they are prefixed with `mise exec --`. For example, a test command in `lefthook.yml` might look like `mise exec -- bundle exec rails test`. This is crucial for the reliability of automated checks.

### Database Seeding

The project includes comprehensive fixture data for development and testing. The database seeding process loads realistic sample data including users, searches, coffeeshops, reviews, and favorites.

**Available Seeding Commands:**

*   `mise exec -- bin/rails db:seed`: Load seed data (preserves existing data)
*   `mise exec -- bin/rails dev:setup`: Clear all data and reload fresh seed data
*   `mise exec -- bin/rails dev:reset`: Alias for `dev:setup`
*   `mise exec -- bin/rails dev:status`: Show current data counts

**Seed Data Details:**

The seeding process loads data from test fixtures located in `test/fixtures/`:
*   **Users**: Sample user accounts with the default password `TerriblePassword`
*   **Searches**: Sample search queries with location coordinates
*   **Coffeeshops**: Sample business data with ratings, addresses, and contact info
*   **Reviews**: User-generated reviews with ratings
*   **User Favorites**: Sample favorite relationships between users and businesses

**Note**: The `bin/setup` script automatically runs `bin/rails db:prepare` which includes seeding. For ongoing development, use `dev:setup` to refresh your development data.

### Common Development Tasks

This project uses `mise` to manage and run common development tasks. You can list available tasks with `mise tasks` or `mise ls`. Here are some key examples:

*   `mise run setup`: Re-run the initial development setup process.
*   `mise run test`: Run all unit and integration tests.
*   `mise run test-system`: Run system tests (e.g., browser-based tests).
*   `mise run lint`: Run all configured linters (e.g., RuboCop for Ruby, Prettier for JavaScript).
*   `mise run fix`: Attempt to automatically fix issues found by linters.
*   `mise run brakeman`: Run the Brakeman security scanner.

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
