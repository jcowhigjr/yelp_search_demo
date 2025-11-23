# Bug: Coffeeshop cards are white in dark mode (Materialize vs Tailwind conflict)

## Summary

In dark mode, coffeeshop cards render with a white background while the page background is dark. This makes the cards visually jarring and breaks the intended dark theme.

## Environment

- App: Jitter (Yelp search demo)
- Frontend stack: Tailwind v4 + Materialize CSS
- Layout: `app/views/layouts/application.html.erb`
- Partial: `app/views/coffeeshops/_coffeeshop.html.erb`

## Actual behavior

- In dark mode, the page background is dark (via `dark:bg-slate-900` on the `<html>` element).
- Coffeeshop cards still render with a bright white background.
- This is visible both locally and on the deployed Heroku app from the feature branch.

## Expected behavior

- In dark mode, coffeeshop cards should have a dark background that matches the rest of the theme (no bright white cards against a dark page).

## Relevant code

Layout loads Materialize first, then Tailwind:

```erb
<!-- app/views/layouts/application.html.erb -->
<html lang="<%= I18n.locale %>" class="dark:bg-slate-900 dark:text-white" dir="<%= t('dir') %>">
  <head>
    ...
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/materialize/1.0.0/css/materialize.min.css">
    ...
    <%= stylesheet_link_tag "tailwind", "data-turbo-track": "reload" %>
    <%= stylesheet_link_tag "application", "data-turbo-track": "reload" %>
  </head>
```

Current coffeeshop card partial:

```erb
<!-- app/views/coffeeshops/_coffeeshop.html.erb -->
<div class="col xl l6 m12 s12">
  <%# Use Tailwind dark: classes to avoid Materialize CSS override conflict.
      Materialize's .card { background-color: #fff } would win over .bg-base utility. %>
  <div class="card large coffeeshop-card dark:bg-slate-900 dark:text-white">
    ...
  </div>
</div>
```

Tailwind application CSS defining theme variables and utilities:

```css
/* app/assets/tailwind/application.css */
:root {
  --color-bg: #fff;
  --color-text: #000;
}

@media (prefers-color-scheme: dark) {
  :root {
    --color-bg: #18181b;
    --color-text: #fff;
  }
}

@layer utilities {
  .bg-base {
    background-color: var(--color-bg);
  }
  .text-base {
    color: var(--color-text);
  }
}
```

And the compiled Tailwind bundle includes the dark-mode utilities we rely on:

```css
/* app/assets/builds/tailwind.css (excerpt) */
.dark\:bg-slate-900 {
  @media (prefers-color-scheme: dark) {
    background-color: var(--color-slate-900);
  }
}
.dark\:text-white {
  @media (prefers-color-scheme: dark) {
    color: var(--color-white);
  }
}
...
.bg-base {
  background-color: var(--color-bg);
}
```

## Root cause

Originally, the card markup used `bg-base text-base`:

```erb
<div class="card large coffeeshop-card bg-base text-base">
```

However, Materialize defines `.card { background-color: #fff; }` in its CSS. Because both `.card` and `.bg-base` are single-class selectors, the cascade between Materialize and Tailwind is fragile and was leading to white cards in dark mode in some environments.

We updated the partial to use explicit Tailwind dark-mode utilities instead:

```erb
<div class="card large coffeeshop-card dark:bg-slate-900 dark:text-white">
```

This avoids the Materialize `.card` conflict by setting a stronger, clearly dark background in dark mode.

## Why it’s still white in the deployed branch

- The Heroku deployment currently running for this feature branch appears to be built from a commit **before** the `_coffeeshop.html.erb` change to `dark:bg-slate-900 dark:text-white`.
- As a result, the deployed app still has the old `bg-base` markup and continues to show white cards, even though the branch now contains the corrected partial and a compiled Tailwind bundle that supports dark mode.

## Guardrails recently added (separate from this bug)

The branch also added two safety mechanisms that do **not** change styling by themselves but help prevent regressions:

1. **Tailwind build verification script**
   - `scripts/verify-tailwind-build.sh` builds the production Tailwind CSS and asserts that:
     - `app/assets/builds/tailwind.css` exists, and
     - Dark-mode tokens like `.bg-base`, `.text-base`, `--color-bg`, and `@media (prefers-color-scheme: dark)` are present.
   - Wired into the `tailwind-build-check` pre-push hook via `lefthook.yml` so pushes fail if the dark-mode utilities are missing.

2. **Coffeeshop card view test**
   - `test/views/coffeeshops_card_test.rb` renders the card partial and asserts that:
     - It includes either `bg-base` or the legacy `dark:bg-slate-900` class, ensuring we don’t accidentally drop dark-friendly styling in future edits.

These guardrails protect future changes but don’t retroactively fix the already-deployed CSS.

## Proposed fix

1. **Ensure the `_coffeeshop.html.erb` change is merged and deployed**
   - Confirm that `app/views/coffeeshops/_coffeeshop.html.erb` in the deployed commit uses:

     ```erb
     <div class="card large coffeeshop-card dark:bg-slate-900 dark:text-white">
     ```

2. **Deploy with a fresh Tailwind build**
   - Run the Tailwind build and verification locally on the branch:

     ```bash
     scripts/verify-tailwind-build.sh
     ```

   - Commit the regenerated `app/assets/builds/tailwind.css` if it changes.
   - Redeploy the branch to Heroku so the new partial + CSS are both live.

3. **Acceptance criteria**
   - In dark mode, coffeeshop cards render with a dark background on both:
     - Local environment (using the feature branch), and
     - The Heroku deployment.
   - `scripts/verify-tailwind-build.sh` passes.
   - `bin/rails test test/views/coffeeshops_card_test.rb` passes.
