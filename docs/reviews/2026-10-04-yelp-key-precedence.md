# Review record - Prefer Heroku Yelp key at runtime (#3036, PR #3038)

## Provenance

| Field | Value |
|-------|-------|
| Date (UTC) | 2026-10-04 |
| Commit(s) reviewed | `9161fe8c4dfc47c5bf18789141d15dc56b5cc7c1` (range `6445996b7c70dda6f2a60f77b386ebec42c00ef5..9161fe8c4dfc47c5bf18789141d15dc56b5cc7c1`) |
| Reviewer | `claude/opus` |
| Invocation | Claude Code CLI session: review of the final commit and its local amendment history, reading `app/controllers/searches_controller.rb`, `app/models/coffeeshop.rb`, `config/locales/*.yml`, `config/routes.rb`, then the verification commands below |
| Requested by | repository owner, interactively |
| Authored the change? | no - the change was authored by a separate Codex session |
| Fresh context? | no - the reviewer saw the author's summary of the change and reviewed three successive iterations, so later passes were informed by its own earlier findings |
| Independent? | no |
| Escalated to human? | no |
| Given | full repo |

## Findings

| # | Severity | Finding | Disposition |
|---|----------|---------|-------------|
| 1 | high | `SearchesController#update` compared the result to `'error'`, but `Coffeeshop.get_search_results` returns `'error: ...'` strings, so Yelp failures on update flashed "Successfully updated search". | fixed in `9161fe8` - `#update` uses `search_error_result?` / `handle_search_error`; covered by `#update renders the translated generic error when Yelp fails` |
| 2 | medium | No test proved Yelp failures avoid logging exception text. | fixed in `9161fe8` - WebMock 401 with a sensitive body; asserts the log has class and status but not the body |
| 3 | low | Key-precedence tests called the private `configured_api_key` via `send`. | fixed in `9161fe8` - tests assert the outgoing `Authorization: Bearer` header via WebMock |
| 4 | low | Logging only `e.class` lost the HTTP status needed to tell a bad key from rate limiting. | fixed in `9161fe8` - logs `e.http_code` when present |
| 5 | low | Trailing whitespace in `Coffeeshop.get_search_results`. | fixed in `9161fe8` |
| 6 | low | `#update` failure test uses `search_url(nil, @search.id)` while the neighbouring test uses `search_url(@search.id)`; correct only because of the optional `(:locale)` route scope. | declined - cosmetic, behaviour verified by passing tests |
| 7 | medium | The Yelp request interpolates `term=#{query}` without URL encoding. | not applicable - pre-existing and outside #3036 scope; no follow-up issue filed yet |
| 8 | medium | `rescue RestClient::Exception` does not catch `SocketError`, `Errno::ECONNREFUSED`, or `JSON::ParserError`, which still surface as 500s. | not applicable - pre-existing and outside #3036 scope; no follow-up issue filed yet |

## Disproved

| Candidate finding | Why it does not hold |
|-------------------|----------------------|
| `search_url(nil, @search.id)` would raise `UrlGenerationError` or build a wrong path. | `config/routes.rb:4` scopes routes under optional `(:locale)`, so `nil` fills the locale; the test passes and asserts the redirect. |
| `t('error.something_went_wrong')` could still raise a missing-translation error. | The key exists under `error:` in `en`, `es`, `fr`, `pt-BR`, and `th` locale files, and other controllers already use it. |
| A whitespace-only `YELP_API_KEY` would be sent to Yelp instead of falling back. | `configured_api_key` uses `.presence`, which treats whitespace-only strings as blank. |
| `yelp_error_status`/`e.http_code` could raise when there is no HTTP response (timeouts). | `RestClient::Exception#http_code` returns `nil` without a response, and the log suffix is omitted when status is nil. |
| Stubbing `Rails.application.credentials.dig` with `.with(:yelp, :api_key)` would break other `dig` calls during the test. | The only `dig` call in the exercised path is in `configured_api_key`; the full suite passes. |

## Not reviewed

- Heroku runtime behaviour after deployment, including whether `YELP_API_KEY` is set on the `dorkbob` app, was not verified.
- Real Yelp API responses; all Yelp traffic in tests is stubbed with WebMock or Mocha.

## Verification

```
mise run test
106 runs, 478 assertions, 0 failures, 0 errors, 0 skips

mise exec -- bin/rails test test/models/coffeeshop_test.rb test/controllers/searches_controller_test.rb
12 runs, 60 assertions, 0 failures, 0 errors, 0 skips

mise exec -- bundle exec rubocop app/controllers/searches_controller.rb app/models/coffeeshop.rb test/controllers/searches_controller_test.rb test/models/coffeeshop_test.rb
4 files inspected, no offenses detected

Pre-push hook:
36 system tests, 169 assertions, 0 failures, 5 skips
```
