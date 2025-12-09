# Issue 1191 – test re-run notes

- Target test: `test/system/locales_test.rb` (system/locales suite).
- Commands executed (twice): `PARALLEL_WORKERS=1 mise exec -- bin/rails test test/system/locales_test.rb`.
- Outcome for both runs: early error before assertions – `Errno::EPERM: Operation not permitted - bind(2) for "0.0.0.0" port 0` raised while Capybara attempted to start its server.
- Flakiness check: rerun reproduced the identical bind error, indicating an environment/permission issue rather than an intermittent test failure.
- Follow-up: need a test environment that allows Capybara to bind to a local port (or alternate host/port configuration) before the test can be validated for functional correctness.
