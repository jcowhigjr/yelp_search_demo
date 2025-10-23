# Speeding up Universal Image Startup

The Codex task runner provisions a new container for each session using the
standard "universal" image. The very first commands you run determine how much
setup work the container has to do before Rails (or any other stack) is ready.
The following tactics have worked well to keep the bootstrapping time down.

## 1. Pre-warm language runtimes with `mise`

* Add the runtime versions you care about (Ruby, Node.js, etc.) to
  [`mise.toml`](../mise.toml) and commit the file.
* Run `mise trust` once locally so the file is marked as trusted; the Codex
  container inherits that trust and will skip the interactive warning.
* The first `mise install` on the universal image downloads toolchains into the
  shared `/root/.local/share/mise/installs` directory. Because the directory is
  cached between jobs, subsequent containers can reuse the toolchains without
  re-downloading.
* If you need a bleeding-edge Ruby that is not cached yet, add a
  `scripts/prewarm_mise.sh` helper that runs during CI to install it once and
  leave the artifacts behind for developers.

## 2. Cache Bundler and Yarn installs

* Teach Bundler to use a shared cache: `bundle config set --global path
  '/workspace/.bundle-cache'`. Commit a small script in `bin/setup` to create the
  directory and apply the config before `bundle install` runs.
* Enable yarn/npm caching the same way: `yarn config set cache-folder
  /workspace/.yarn-cache`.
* Check `Gemfile.lock` and `package-lock.json` into the repository so the first
  install can resolve quickly.

## 3. Skip work you do not need

* Gate optional services (ChromeDriver, Playwright, etc.) behind environment
  variables so they are only installed when required by the test suite.
* Defer `rails db:setup` unless a particular test actually requires a database.
  Many controller/unit suites can run against the in-memory test DB.

## 4. Snapshot the warmed environment

* If you own the task, capture a `docker commit` of the fully warmed container
  and use it as the base image for future runs. This works well when you have a
  stable set of dependencies.
* For shared environments, use GitHub Actions or another CI system to publish a
  periodically refreshed warm image that already contains your Ruby version and
  gem cache.

## 5. Measure and iterate

* Add timestamps around the expensive steps in your `bin/setup` and test
  scripts so you can see the payoff as caches warm.
* Track the per-step timing in `docs/test_runs/` so the team can compare runs
  and understand when the cache was cold versus hot.

By combining mise pre-warming, dependency caches, and selective setup, most
projects can get their Rails unit test containers ready in under a minute once
caches are primed.
