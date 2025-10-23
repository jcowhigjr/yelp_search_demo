# Rails Unit Test Run - 2025-02-14

- **Command:** `bin/rails test`
- **Environment:** ruby 3.4.4 (via mise), bundler 2.7.1
- **Result:** ✅ Command executed, ❌ suite reported **3 errors**

## Error Summary

1. `SearchesControllerTest#test_#create`
2. `SearchesControllerTest#test_#update`
3. `SearchesControllerTest#test_#update_changes_query`

All three errors failed in `Coffeeshop.get_search_results` when trying to index into a `nil` object at `app/models/coffeeshop.rb:20`.

## Notes

- Dependencies were installed locally with `bundle install --path vendor/bundle`.
- Tailwind build artifacts and test SQLite databases were reset after the run to keep the working tree clean.
- Container setup was slow because `mise` had to download and install Ruby 3.4.4 in a fresh environment, and Bundler fetched ~200 gems (several with native extensions such as `pg` and `ffi`) with no prior cache. Subsequent runs on the same image should reuse those assets and complete significantly faster.
