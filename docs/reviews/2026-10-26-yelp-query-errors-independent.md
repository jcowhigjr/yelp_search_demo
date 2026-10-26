# Review record - fix: encode Yelp queries and handle connection failures (PR #3045, independent pass)

## Provenance

| Field | Value |
|-------|-------|
| Date (UTC) | 2026-10-26 |
| Commit(s) reviewed | `40fd7aa1babccaf3a3f4219b3bcd13a7d703d04a`, `bbaa97c4772c3bc2ac42a1f0eb5741dedde2f6f9`, `cf955edb4f29b502b48ba4f4e5f9aa31a0ef2b56` (range `3a4c231f684f9e15a466383ddd90e1c657f12b5f..cf955edb4f29b502b48ba4f4e5f9aa31a0ef2b56`) |
| Reviewer | `devin/SWE-2` |
| Invocation | Devin Desktop agent session: review of the PR #3045 diff against `develop`, reading `app/models/coffeeshop.rb`, `app/controllers/searches_controller.rb`, `test/models/coffeeshop_test.rb`, `test/controllers/searches_controller_test.rb`, `lefthook.yml`, `.rubocop.yml`, `.rubocop_todo.yml`, issue #3040 acceptance criteria, then the verification commands below |
| Requested by | repository owner, interactively |
| Authored the change? | no - the change was authored by a separate codex/gpt-5 session |
| Fresh context? | yes - the reviewer saw the diff and the issue, not the reasoning that produced the code |
| Independent? | yes |
| Escalated to human? | no |
| Given | full repo |

## Findings

| # | Severity | Finding | Disposition |
|---|----------|---------|-------------|
| 1 | medium | The PR introduced three RuboCop offenses in `test/models/coffeeshop_test.rb`: `Metrics/ClassLength` (110/100), `Metrics/BlockLength` on `CONNECTION_ERRORS.each` (11/10 - `test` is in `AllowedMethods` but `each` is not), and `Minitest/EmptyLineBeforeAssertionMethods`. The pre-push `rubocop` hook lints changed `.rb` files, so this debt would surface on the next Ruby-touching push. | fixed - moved the new tests to `test/models/coffeeshop_yelp_request_test.rb` and extracted the error assertion into a helper; `coffeeshop_test.rb` returns to its `develop` state |
| 2 | low | `OpenSSL::SSL::SSLError`, `Net::OpenTimeout`-family errors that bypass RestClient's wrapping, and `URI::InvalidURIError` remain unrescued and would still surface as 500s. | declined - outside issue #3040's stated error list; the encoded `params` hash makes malformed-URL input unlikely; noted for a future hardening pass |

## Disproved

| Candidate finding | Why it does not hold |
|-------------------|----------------------|
| `headers: { params: {...} }` might not be applied to GET requests, silently dropping the query. | RestClient merges `headers[:params]` into the URL query for GET via `process_url_params`; proven empirically - the WebMock capture test decodes `captured_request.uri.query` and asserts the round-tripped `term` value and the exact param set. |
| `e.respond_to?(:http_code)` could itself raise or hide the HTTP status on `RestClient::Exception`. | `RestClient::Exception#http_code` is a real method returning `nil` without a response; non-RestClient errors don't respond, so `suffix` is `''`. The 401 test asserts `RestClient::Unauthorized.*HTTP 401` in the log. |
| The raw `'error: ...'` string could be flashed to the user, leaking the fallback message. | `SearchesController#handle_search_error` only shows the raw string when it includes `'not configured'`; the generic Yelp failure string takes the `t('error.something_went_wrong')` branch, covered by existing controller tests at `searches_controller_test.rb:60` and `:124`. |
| Timeout errors still bypass the rescue. | `RestClient::Exceptions::Timeout` and `RequestFailed` are `RestClient::Exception` subclasses, already rescued. |
| The exception class name in the log could embed upstream detail (e.g. response body). | `e.class` interpolates the class name only - `SocketError`, `Errno::ECONNREFUSED`, `JSON::ParserError` - never the message; the regression tests assert `sensitive upstream details` is absent from the log. |
| `assert_equal %w[latitude longitude term], params.keys.sort` could be flaky if RestClient re-orders or adds params. | `URI.decode_www_form` preserves whatever arrives; the test passed and asserts the exact set, so any added param would fail loudly. |

## Not reviewed

- Real Yelp API traffic; all requests in tests are stubbed with WebMock or Mocha.
- Production runtime behaviour after merge (Heroku `YELP_API_KEY` state unchanged by this PR).
- The fix commit moving the regression tests into `test/models/coffeeshop_yelp_request_test.rb` was authored by this session after the review findings above; it is test-only reorganization verified by the commands below.

## Verification

```
mise exec -- bundle exec rubocop app/models/coffeeshop.rb test/models/coffeeshop_test.rb test/models/coffeeshop_yelp_request_test.rb
3 files inspected, no offenses detected

mise exec -- env CI=true RAILS_ENV=test bin/rails test test/models/coffeeshop_test.rb test/models/coffeeshop_yelp_request_test.rb test/controllers/searches_controller_test.rb
17 runs, 83 assertions, 0 failures, 0 errors, 0 skips

gh pr checks 3045
All required checks green on cf955ed (test, test-next, CodeQL, provenance, claude-review); re-run expected on the fix commit.

./scripts/review-loop.sh
No unresolved review threads on PR #3045.
```
