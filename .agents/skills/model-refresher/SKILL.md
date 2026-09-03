---
name: model-refresher
description: Use this skill when the user asks about model capabilities, benchmarks, reasoning effort settings, or best practices for using Gemini or other models in yelp_search_demo.
---

# Model Refresher & Capability Optimizer for Yelp Search Demo

This skill guides the agent in presenting an updated model overview, benchmark analysis, and repo-specific tuning advice when a user asks about model capabilities or when a new model is introduced.

---

## 1. Quick Model Assessment

When invoked:
1. Identify the active model (e.g. Gemini 3.8 Flash, Gemini 3.7 Flash, Gemini Pro).
2. Report the model's primary strengths and benchmark profile.
3. Recommend optimal settings for Antigravity (reasoning effort, tool execution policy).
4. Review the core repo invariants.

---

## 2. Model Profiles Reference

### Gemini 3.8 Flash
* **Strengths**: 90.8% Terminal-Bench 2.1; specialized for long-horizon autonomous coding and terminal self-correction.
* **Reasoning Effort Recommendation**:
  * `medium`: Default setting. Ideal for routine feature coding, test writing, and bug fixes.
  * `high`: Ideal for `/goal` sessions involving full-suite test failures, complex Stimulus/Turbo interactions, or multi-commit PR review loops.
* **Prompting Strategy**:
  * Provide end-state goals rather than micromanaging individual shell steps.
  * Point directly to `mise run test` and `mise run test-system` as the definition of done.

### Gemini 3.7 Flash
* **Strengths**: Low latency, responsive coding, solid general tool execution.
* **Reasoning Effort Recommendation**: `medium`.
* **Prompting Strategy**: Great for interactive pair programming, single-file edits, and quick doc updates.

---

## 3. Checklist for User Orientation

When presenting to the user:
- [ ] Active model confirmed.
- [ ] Suggested reasoning effort stated.
- [ ] Toolchain (`mise`) confirmed.
- [ ] Safe git staging (no `git add .`) confirmed.
- [ ] Test verification commands highlighted.
- [ ] Useful slash commands suggested (`/goal`, `/grill-me`).
