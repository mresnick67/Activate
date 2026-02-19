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
- Adding an exercise inserts 3 `WorkoutSet` rows, but set rows are placeholders (no inline entry yet).
- Default exercises seeded from `DefaultExercises.json` (**91** exercises).

---

## Next implementation plan (ordered)

### 1) BQ-007 — Set logging UI

**Design goals**
- Inline set row editing (no modal per set)
- Low-error numeric entry (constraints at input)
- One-thumb, fast progression through fields

**Technical approach (SwiftUI + SwiftData)**
- Create a `WorkoutSetRowView(set: WorkoutSet)` that edits:
  - `weight: Double?` (decimal keypad)
  - `reps: Int?` (number pad)
  - `rpe: Double?` (decimal keypad; optional)
  - `isCompleted` + `completedAt` coherence
- Use `@Bindable var set: WorkoutSet` (SwiftData) or explicit bindings to avoid copy-on-write issues.
- Use `FocusState` to manage field progression.
- Keep formatting consistent (e.g., 0–2 decimals for weight, 0–1 for RPE) and never crash on nil.

**UX quality/ergonomics action (required this sprint)**
- Implement a "Repeat Last" affordance OR ghost previous values, as described in `UIUX-INSPIRATION.md`, to reduce typing.

### 2) BQ-008 — Rest timer capsule

- Timer should be visible within `ActiveWorkoutView` and start when a set is marked completed.
- MVP persistence can be deferred; keep timer state in the workout view model.

### 3) BQ-009 — Finish workout + summary

- Add explicit "Finish" action in `ActiveWorkoutView`.
- Persist `completedAt` + `durationSeconds`.
- Summary UI must show facts first (duration, completed sets, volume) before any interpretive copy.

### 4) BQ-010/011 — History + detail

- Replace placeholder history view with a list from SwiftData.
- Add drill-in to a read-only workout detail screen.

---

## Open decisions / watchouts

- Where to store per-exercise rest defaults (template vs exercise vs view model only).
- How to compute volume consistently (exclude warmups? handle bodyweight?). Define MVP rule and document.
- SwiftData editing patterns: ensure updates persist and don’t require explicit saves in every keystroke.
