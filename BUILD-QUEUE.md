# Activate — Build Queue

Last updated: **2026-02-20 02:10** (America/Toronto)

Status: **DONE / IN-PROGRESS / NEXT / BLOCKED / PARKED**

This queue is the source of truth for "What’s Next" in README.

---

## Completed (MVP foundation)

Evidence basis: current repo contents under `LiftKit/` + recent git history.

- **DONE (BQ-001)** App scaffold + tab shell (Home / History / Exercises / Settings)
- **DONE (BQ-002)** SwiftData models: `Workout`, `WorkoutSet`, `Exercise`, `WorkoutTemplate` (+ enums)
- **DONE (BQ-003)** Default exercise seed system (`DefaultExercises.json` = **91** items) + idempotent seeding
- **DONE (BQ-004)** Exercise Library (search + category filter) + Exercise Detail screen
- **DONE (BQ-005)** Start Workout flow (Home → full-screen `ActiveWorkoutView`, creates `Workout` on appear)
- **DONE (BQ-006)** Add Exercise to active workout via picker (creates default **3** placeholder sets per exercise)
- **DONE (BQ-007)** Set logging UI (inline entry + completion + add/delete + focus progression)
  - Added `WorkoutSetRowView` with inline `weight/reps/RPE` entry.
  - Added completion toggle (`isCompleted` + `completedAt` coherence).
  - Added swipe-to-delete set rows and inline **Add Set** action.
  - Added keyboard toolbar flow (**Next/Done**) to move `weight → reps → RPE → next set`.
  - Added field-level numeric constraints + visible invalid-state border + "Last" ghost + **Repeat** action.
- **DONE (BQ-008)** Rest timer capsule (non-modal, attached to set completion)
  - Auto-starts when a set is marked complete in `WorkoutViewModel.toggleSetCompletion`.
  - Added inline rest capsule in `ActiveWorkoutView` with visible countdown + `-15s / +15s / Skip` controls.
  - Timer state is safely managed in view model (`restTimeRemainingSeconds`) and cleared on skip/dismiss.
- **DONE (BQ-009)** Finish workout + save flow (facts first)
  - Added finish action in `ActiveWorkoutView` with empty-workout guardrail confirmation.
  - Added `WorkoutViewModel.finishWorkout(...)` to persist `completedAt` + `durationSeconds`.
  - Enforced set completion timestamp coherence at finish time.
  - Added `WorkoutSummaryView` facts-first modal (duration, completed sets, logged volume, timing).

---

## Next (focus: history trust)

### **DONE (BQ-010)** History list (trust-first scanability)
- Added SwiftData-backed workout fetch in `HistoryListView` with dedicated **Completed** + **In Progress** sections.
- Implemented trust-first row layout in fixed metric order: date/time, duration, completed set count, logged volume.
- Added explicit status chips (`Completed` / `In Progress`) + subtle in-progress row tint for fast visual distinction.
- Applied scanability ergonomics: monospaced numeric metrics, consistent alignment, and padded row tap targets.

### **NEXT (BQ-011)** Workout detail (read-only, provenance + disclosure)
- Drill-in from History to view exercises/sets logged (read-only)
- Preserve exercise order + set completion state exactly as logged
- Reuse finish-summary framing at top (duration, completed sets, logged volume)
- Footer disclosure: `Source`, `Last updated`, and `Volume formula: Σ(weight × reps) for completed loaded sets`

---

## Blocked
- Runtime build verification remains blocked on host toolchain:
  - `xcodebuild` unavailable (`xcode-select` points to CommandLineTools).

---

## Parked (post-MVP)
- Live Activity / lock screen timer
- HealthKit import/export
- AI coaching UI (only after trust-first summary is solid)
