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
- Default exercises seeded from `DefaultExercises.json` (**91** exercises).

---

## Next implementation plan (ordered)

### 1) BQ-009 — Finish workout + summary

- Add explicit "Finish" action in `ActiveWorkoutView`.
- Persist `completedAt` + `durationSeconds`.
- Summary UI must show facts first (duration, completed sets, volume) before any interpretive copy.
- Include an empty-workout guardrail (confirm if no completed sets).

### 2) BQ-010 — History list

- Replace placeholder history view with a real list from SwiftData.
- Show factual row summaries (date, duration, set count, volume).
- Handle empty-state and in-progress filtering intentionally.

### 3) BQ-011 — Workout detail (read-only)

- Drill-in from history rows to a read-only workout detail screen.
- Preserve set/exercise ordering and show completion state clearly.

---

## Open decisions / watchouts

- Where to store per-exercise rest defaults (template vs exercise vs view model only).
- How to compute volume consistently (exclude warmups? handle bodyweight?). Define MVP rule and document.
- SwiftData editing patterns: ensure updates persist and don’t require explicit saves in every keystroke.
