# Auth Flow – Login and Signup

## Goal

Make login and signup forms visually consistent with the prototype, using shared tokens and layout patterns, while keeping all authentication behavior unchanged.

## Surfaces

- Login: `sessions#new`
  - View: `app/views/sessions/new.html.erb`
- Signup: `users#new`
  - View: `app/views/users/new.html.erb`

## UX expectations

- Centered card or panel layout for forms.
- Consistent input styling (padding, borders, focus state).
- Clear primary button (Log In / Sign Up) and secondary links (e.g., to signup/login, password help if present).
- Typography aligned with `page-name` for headings and `page-text` for supporting copy.

## Constraints

- Do not change the underlying authentication logic or routes.
- Keep field names and error messaging intact.
- Ensure error messages remain visible and accessible after styling changes.

## Tests to touch

- System tests covering login/logout and signup flows.

## Agent checklist

When working on auth-related changes (Phase 6):

1. Read this document plus `implementation-plan.md` Phase 6.
2. Adjust only the **view layout and classes**; do not alter form field names or routes.
3. Verify error states manually (e.g., submit with invalid credentials) to ensure messages are still shown.
4. Run the existing login/signup system tests before opening a PR.
