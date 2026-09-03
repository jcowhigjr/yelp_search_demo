# Model Capability & Best Practices Refresher Rule

This rule ensures that whenever a new model (or a new conversation) is initiated, the agent reviews model capabilities, adjusts reasoning parameters, and presents an actionable orientation to the user.

---

## 1. When to Trigger a Model Refresher

The agent MUST present a refresher when:
* Starting a new conversation in this project and confirming the baseline setup.
* Receiving a model transition signal from `hooks.json` or noticing a model change in system settings.
* Explicitly requested by the user ("what can this model do?", "overview of capabilities", "refresh tips").

---

## 2. Gemini Model Calibration Matrix for `yelp_search_demo`

| Model Family | Benchmark Profile | Recommended Reasoning Effort | Optimal Use Case in this Repo |
| :--- | :--- | :--- | :--- |
| **Gemini 3.8 Flash** | 90.8% Terminal-Bench 2.1, strong autonomous tool loops | **Medium** (default)<br>**High** (deep refactor / Cuprite debug) | Daily development, running test suites, `/goal` workflows, fixing PR review comments. |
| **Gemini 3.7 Flash** | Fast reasoning, standard tool execution | **Medium** | Minor bug fixes, documentation, routine code reviews. |
| **Gemini Pro** | Maximum reasoning depth, large refactors | **High** | Major architectural overhaul, complex multi-file database migrations. |

---

## 3. Standard Refresher Checklist

When delivering a refresher, include:
1. **Model & Reasoning Setting**: State the active model and suggested reasoning effort for the current task.
2. **Key Capabilities**: Highlight Terminal-Bench strength, tool reliability, and long-horizon goal attainment.
3. **Repo Invariant Reminders**:
   - `mise exec --` execution.
   - Strictly explicit git staging (NEVER `git add .` or `git add -A`).
   - Empirical verification: run `mise run test` and `mise run test-system` before declaring victory.
4. **Slash Command Recommendations**:
   - `/goal` for autonomous tasks that run to full completion without micromanagement.
   - `/grill-me` when clarifying ambiguous product requirements.
   - `/learn` when persisting local setup or debugging discoveries into agent memory.
   - `/browser` when inspecting live UI views or testing interactive Hotwire components.
