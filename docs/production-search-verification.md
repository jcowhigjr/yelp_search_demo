# Production search verification

Tracks #3052; incident #3050. This verifier has no Heroku API token and does not change deployment credentials or environment protections.

## Build identity

The Heroku Ruby build invokes assets:precompile. A Rake prerequisite writes config/build_revision from the platform-provided SOURCE_COMMIT at build time. The value must be a full lowercase Git SHA. Builds without metadata overwrite any stale file with unknown. Git, runtime config variables, request input, and manually supplied workflow revision values do not populate the serving marker.

ApplicationController returns X-App-Revision from that artifact on dynamic responses. It exposes only the SHA of this public repository. Unknown identity fails production verification. Static assets and platform/router-generated errors do not necessarily have this header and are not used to prove serving identity.

## Trust boundaries

PR-triggered runs execute the checker tests with simulated responses, no production credentials, and no intended production HTTP submissions. This is not a network sandbox for arbitrary PR code; malicious code could still call the public site like any client.

Live probes run only after successful push-triggered Rails CI on this repository's develop branch, or explicit dispatch on develop. They execute the verifier from develop and compare the serving build with the triggering commit. They do not checkout PR code, fetch pipeline artifacts, or grant write permissions.

Dependency actions are pinned to immutable SHAs. Checkout does not persist Git credentials. Review workflow/script/build-marker changes through the normal PR protections.

## Assertions and side effects

Poll health for the expected revision before any POST. Require the same revision on the homepage, POST redirect, and result page. Require an exact same-origin saved-search URL, HTTP 200 result, and search-result/business-card markers. Invalid identity, changed revision, collection/error redirect, or unexpected HTTP response fails. TLS validation stays enabled.

Two fresh anonymous synthetic searches are submitted per live run, with the fixed incident reproduction inputs. CSRF/session handling is normal; POSTs are not retried. Each run creates ordinary searches and outcome events and uses the app's Yelp quota. No record deletion or schema change is performed. Broader continuous monitoring and synthetic-data tagging/retention are not implemented by this PR.

Only selected statuses, query labels, member paths, timestamps, and verified revision are retained for seven days. Do not upload cookies, authenticity tokens, authorization headers, response bodies, environment dumps, or arbitrary exception messages.

## Rollout and evidence

The workflow cannot verify its own new header before this application change deploys. After merge, a successful Heroku build emits the artifact; trusted verification waits for the expected SHA then exercises search. A failed check does not roll back or deploy anything. Do not close #3050 until that production run passes.

This adds a post-deployment check, not a prerequisite for Heroku to begin the same deployment. Existing health checks remain in place. The existing native Heroku integration and CI-wait settings require separate configuration verification.

## Validation

Run ruby test/scripts/production_verification_test.rb for isolated protocol/security-boundary tests. Run the Rails controller test through mise exec -- bin/rails test test/controllers/build_revision_header_test.rb. CI performs the repository's existing required Rails checks.

Sources: https://devcenter.heroku.com/articles/heroku-24-stack ; https://docs.github.com/en/actions/reference/security/secure-use .
