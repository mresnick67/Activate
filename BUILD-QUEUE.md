# Activate — Build Queue

Last updated: **2026-02-19 02:10** (America/Toronto)

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

---

## Next (focus: logging ergonomics + trust)

### **NEXT (BQ-008)** Rest timer capsule (non-modal, attached to set completion)
**UX:** Auto-start on set completion; inline `-15s / +15s / Skip` controls; always visible on workout screen.

**Tech notes**
- MVP can keep timer state in-memory (view model) if persistence is unclear
- If persisting: decide where rest defaults live (template vs exercise metadata)

---

### **NEXT (BQ-009)** Finish workout + save flow (facts first)
**UX:** Summary must present verifiable facts (duration, sets completed, volume) before any AI interpretation.

**Tech notes**
- Set `Workout.completedAt` and `Workout.durationSeconds`
- Ensure sets are saved and completion timestamps are consistent

---

### **NEXT (BQ-010)** History list (replace placeholder)
- Fetch workouts (completed + in-progress handling)
- Show basic row summary (date, duration, set count / volume)

### **NEXT (BQ-011)** Workout detail (read-only)
- Drill-in from history to view exercises/sets logged

---

## Blocked
- Runtime build verification remains blocked on host toolchain:
  - `xcodebuild` unavailable (`xcode-select` points to CommandLineTools).

---

## Parked (post-MVP)
- Live Activity / lock screen timer
- HealthKit import/export
- AI coaching UI (only after trust-first summary is solid)
