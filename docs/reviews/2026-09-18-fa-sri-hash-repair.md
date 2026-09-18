# Review record - repair Font Awesome SRI hash (#3016)

## Provenance

| Field | Value |
|-------|-------|
| Date (UTC) | 2026-09-18 |
| Commit(s) reviewed | working-tree diff on `bugfix/issue-3016-fa-sri` (layout line 13 + new `test/system/font_awesome_delivery_test.rb`) |
| Reviewer | devin subagent (subagent_explore) / SWE-2 |
| Invocation | `run_subagent` with the changed-file list, the issue context, and instructions to disprove each candidate finding before reporting it |
| Requested by | devin (authoring agent), per Route B in docs/AGENTS.md |
| Authored the change? | no |
| Fresh context? | yes - the reviewer saw only the repository state and the changed-file list, not the authoring session's reasoning |
| Independent? | yes |
| Escalated to human? | no |
| Given | full repo - reviewer read the changed files plus layouts, importmap.rb, application.js, application_system_test_case.rb, routes.rb, and sibling system tests |

## Findings

| # | Severity | Finding | Disposition |
|---|----------|---------|-------------|
| 1 | low | Cuprite launches Chrome with `disable-web-security`, so the `cssRules` probe stays readable even without cdnjs CORS; a future CORS-only regression would slip past it | declined - narrow edge; the SRI-block regression it targets is still caught (verified red below) |
| 2 | low | The `svg.fa-google`/`fa-facebook` test exercises the importmap JS path, not the CSS link; redundant with existing `svg.fa-yelp` coverage | accepted as complementary icon coverage; the `cssRules` test is the real SRI guard |
| 3 | low | Live-CDN dependence at test time | declined - materialize/jspm/Google-fonts CDNs are already fetched by existing system tests; consistent exposure |
| 4 | nit | `wait: 5` is shorter than the Capybara default | harmless |

## Disproved

| Candidate finding | Why it does not hold |
|-------------------|----------------------|
| New hash might also be wrong | Matches cdnjs's published SRI for FA 6.5.1 all.min.css; recomputed via openssl from live bytes |
| Other layouts/tags need the fix | Only SRI-bearing tag in the repo; mailer/turbo_stream layouts have no links |
| `svg.fa-*` selectors invalid | FA svg-with-js preserves the icon class; `svg.fa-yelp` precedent in coffeeshops_test.rb |
| False match from FA-JS `<style>` nodes | Inline style nodes have `href === null`; jspm URL lacks the `font-awesome` substring |
| Fonts-blocked driver aborts cdnjs | `ferrum_block_fonts` only aborts `fonts.gstatic.com`; not the active driver |
| CSP blocks cdnjs | `content_security_policy.rb` is entirely commented out |
| Timing flake in the probe | `visit` waits for load; stylesheets are load-blocking |

## Not reviewed

Actual test execution by the reviewer (relied on author's reported runs); production deploy behavior.

## Verification

```
# Red/green proof against the stale hash:
git stash push -- app/views/layouts/application.html.erb
bin/rails test test/system/font_awesome_delivery_test.rb
  -> 1 failure: "Expected -1 to be > 0" (SRI-blocked sheet yields no document.styleSheets entry)
git stash pop -> 2 runs, 4 assertions, 0 failures

bin/rails test test/system/coffeeshops_test.rb
5 runs, 47 assertions, 0 failures

Playwright WebKit 26.6 against dev server:
  / and /login -> 200, faCssRules=1955, faIcons render, zero console errors
```
