# Copilot Instructions for DorkBob (Yelp Search Demo)

## 🚨 CRITICAL: Read First - Workflow Requirements

This project has **mandatory automated git workflow protection**. Before any changes:

1. **ALWAYS** start with: `lefthook run workflow-status`
2. **NEVER** commit directly to `main` or `develop` branches
3. **USE** lefthook commands instead of direct git operations:
   - `lefthook run workflow-new-feature fix/description` (create branches)
   - `lefthook run fixer` (code quality fixes before commit)

**Required reading**: `/docs/agent-coder-workflow.md` and `/docs/AGENTS.md`

## Project Architecture

### Core Stack
- **Rails 8.1.0.beta1** with Ruby 3.4.4
- **Yelp Fusion API** integration for business search
- **Hotwire/Turbo** for dynamic UI updates
- **Google OAuth** for authentication
- **PostgreSQL** (prod) / **SQLite3** (dev)
- **Tailwind CSS v4** for styling

### Key Domain Models
- `User` - OAuth authentication with favorites
- `Coffeeshop` - External Yelp business data (not persisted)
- `Search` - User search queries and parameters  
- `Review` - User-generated reviews for businesses
- `UserFavorite` - Many-to-many relationship for saved places

### Service Layer Pattern
Use `app/services/` for external API calls and complex business logic. See `DemoService` for structure pattern.

## Development Commands

### Essential Setup
```bash
bin/setup              # Initial project setup (uses mise)
bin/dev               # Start development server
```

### Code Quality (Required Before Commits)
```bash
lefthook run fixer    # Auto-fix linting issues
mise run test         # Unit/integration tests
mise run test-system  # System tests (Cuprite/headless)
mise run brakeman     # Security scanning
```

### Tool Management
This project uses **mise** (not rbenv/nvm) for tool version management:
- All versions defined in `mise.toml`
- Commands prefixed with `mise exec --` in hooks
- Ruby, bundler managed via mise

## Critical Development Patterns

### Turbo/Hotwire Integration
- Controllers return Turbo Stream responses for dynamic updates
- Use `turbo_stream.erb` templates for partial page updates
- Review `reviews_controller.rb` for Turbo error handling patterns

### Internationalization (i18n)
- All routes wrapped in locale scope: `scope '(:locale)'`
- Locale set per request via concern in `app/controllers/concerns/locales.rb` (wraps each action, adds default_url_options)
- See `app/controllers/concerns/locales.rb` for resolve_locale logic

### Feature Flags
- Flipper integration via `FlipperHelper` concern
- Use `flipper_enabled?(:feature_name)` in controllers/views

### External API Integration
- Yelp Fusion API calls handled via service objects
- Encrypted credentials for API keys (`rails credentials:edit`)
- REST client for HTTP requests

## Testing Strategy

### Mobile-First Development
- Default system tests emulate iPhone SE viewport
- Use `HEADLESS=true CUPRITE=true` for consistent CI testing

### Test Environment
- Database prepared via `mise run test-prepare`
- System tests use Cuprite (Chrome headless)
- Comprehensive test coverage enforced by CI

## Security & Compliance

### Automated Security Scanning
- **Brakeman** runs on every commit via lefthook
- **Bundle audit** checks for vulnerable gems
- **JavaScript audit** via npm audit

### Branch Protection
- Pre-commit hooks prevent direct commits to protected branches
- Pre-push hooks run full test suite
- Quality gates enforced before merge

## GitHub Operations

**Use GitHub CLI (`gh`) for all GitHub operations** - already configured with full permissions:
```bash
gh pr create --title "Title" --body "Description"
gh pr comment <number> -b "@copilot-reviewer review"
gh pr merge --auto --squash <number>
```

## Common Gotchas

1. **Lefthook Installation**: If `lefthook` command fails, install via: `bundle exec lefthook install`
2. **Branch Switching**: Never checkout main/develop directly - use protected workflow commands
3. **Environment Variables**: Use `rails credentials:edit` for secrets, not `.env` files
4. **Asset Pipeline**: Uses Propshaft (not Sprockets) - different import syntax
5. **Tailwind Build**: Run `bin/rails tailwindcss:build` before tests

## Repository Structure Notes

- `/docs/` - Extensive workflow and architecture documentation
- `/scripts/` - Automation scripts for CI/CD and GitHub integration
- `/app/services/` - External API integrations and business logic
- `Gemfile.next` - Rails upgrade testing (dual-version support)