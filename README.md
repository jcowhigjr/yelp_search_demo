# DorkBob needs a name

A pretty generic Ruby on Rails 7 application that allows users to find anything near them by topic, utilizing the Yelp Fusion API.

Use the application at https://dorkbob.herokuapp.com

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
