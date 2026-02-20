# Activate — Dev Plan (Swift-native iOS MVP)

Last updated: **2026-02-19**

This plan is kept intentionally narrow: ship a reliable, fast workout logger before any AI layer.

---

## MVP definition (must-have)

1) Seed exercise library (bundled JSON)
2) Start workout
3) Add exercises to workout
4) Log sets quickly (weight/reps/RPE + completion)
5) Rest timer that doesn’t interrupt logging
6) Finish workout → save → view in history

Non-goals for MVP: backend sync, social, templates complexity, HealthKit writeback, LLM coaching.

---

## Current state (evidence-based)

- App lives under `LiftKit/`.
- Tab shell exists: Home / History / Exercises / Settings.
- Models present: `Workout`, `WorkoutSet`, `Exercise`, `WorkoutTemplate`.
- Active workout creates a `Workout` on appear.
- Adding an exercise inserts 3 `WorkoutSet` rows with full inline logging.
- Set logging is live (`weight/reps/RPE`, completion toggle, add/delete set, keyboard focus progression, repeat-last).
- Rest timer capsule is live (auto-start on completion, `-15s/+15s/Skip`, non-modal).
- Finish flow is live with facts-first post-workout summary and empty-workout guardrail confirmation.
- Workout completion now persists `completedAt` + `durationSeconds`, and reconciles set completion timestamps before save.
- Default exercises seeded from `DefaultExercises.json` (**91** exercises).

---

## Next implementation plan (ordered)

### 1) BQ-010 — History list

- Replace placeholder history view with a real list from SwiftData.
- Show factual row summaries (date, duration, completed set count, logged volume).
- Handle empty-state and in-progress filtering intentionally.
- Surface completion status clearly to avoid accidental trust gaps.

### 2) BQ-011 — Workout detail (read-only)

- Drill-in from history rows to a read-only workout detail screen.
- Preserve set/exercise ordering and show completion state clearly.
- Reuse the same factual summary framing as finish flow (duration, sets, volume).

---

## Open decisions / watchouts

- Where to store per-exercise rest defaults (template vs exercise vs view model only).
- Volume rule is now MVP-defined as: sum of `weight * reps` for completed sets with explicit load logged. Follow-up needed for bodyweight-only movement handling in V2.
- SwiftData editing patterns: ensure updates persist and don’t require explicit saves in every keystroke.
