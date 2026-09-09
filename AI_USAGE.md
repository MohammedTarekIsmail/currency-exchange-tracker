# AI Usage Log

This document tracks how AI was used throughout this project, end to end.
Each entry includes: the prompt, what the AI returned, and whether it was
accepted, edited, or rejected — and why.

---

## Prompt: Read ASSIGNMENT.md and AI_USAGE.md for context before building

**Full prompt:** Before we start building, read ASSIGNMENT.md in the project root, that's the full
spec for what I'm making. Also check AI_USAGE.md so you know the format Im logging in. Confirm you
have read both and give me a quick summary of the app so I know you have got it right before I give
you the actual build instructions. Then append an entry to AI_USAGE.md for this step so I can make
sure that you read ASSIGNMENT.md and AI_USAGE.md to get context before starting any actual coding.
**AI response summary:** Read both files. Summarized the app: a Flutter Currency Exchange Tracker
with three modules — an exchange rates list (5 currencies vs EGP with daily change, pull-to-refresh,
loading/error/empty states), a currency detail screen with a 7-day historical line chart and shimmer
loading, and an offline caching layer with last-updated indicator and auto-refresh on reconnect.
Noted the currency-api.pages.dev endpoints, the EGP-base rate inversion, and the evaluation
criteria (architecture, BLoC separation, error handling, testing, git history). No code generated in
this step.
**Action:** Accepted as-is.