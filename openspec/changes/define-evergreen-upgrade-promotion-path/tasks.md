## 1. Upgrade Classification

- [ ] 1.1 Define the upgrade classes covered by the promotion path: Ruby patch, Ruby minor, stable Rails, and prerelease Rails next lane.
- [ ] 1.2 Map the current evergreen workflows and Dependabot flows to those upgrade classes.

## 2. Promotion Gates

- [ ] 2.1 Define the verification evidence required before each upgrade class becomes a reviewable PR.
- [ ] 2.2 Define the approval and ownership rules for higher-risk upgrade classes.

## 3. Adoption Process

- [ ] 3.1 Document how validated upgrades move from automation output to proposed work, review, and merge.
- [ ] 3.2 Document who closes the loop when automation detects an upgrade but cannot safely merge it.
