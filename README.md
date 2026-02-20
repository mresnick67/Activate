# LiftKit (working name: Activate)

Swift-native iOS workout tracker focused on reliable logging, data portability, and practical coaching insights.

- Platform: iOS 17+
- Stack (current): SwiftUI, SwiftData
- Stack (planned, post-MVP): HealthKit, OpenAI API
- Architecture: local-first MVP (backend deferred to V2)

## What’s Complete

_Last updated: **2026-02-20**_

- App scaffold is in place (`LiftKit/` SwiftUI app + TabView shell: Home / History / Exercises / Settings).
- Core SwiftData models are implemented: `Workout`, `WorkoutSet`, `Exercise`, `WorkoutTemplate` (plus enums).
- Exercise seed system is implemented (first-launch idempotent seeding from `DefaultExercises.json` = **91** exercises).
- Exercise Library is implemented (search + category filter + detail view).
- Start Workout flow is implemented:
  - Home → full-screen `ActiveWorkoutView`
  - Creates a `Workout` on appear
  - Add Exercise via picker (inserts default **3** set rows per exercise)
- Set logging UI is implemented in workout flow:
  - Inline `weight/reps/RPE` entry with numeric constraints
  - Set completion toggle with timestamp coherence
  - Inline Add Set + swipe-to-delete
  - Keyboard toolbar focus progression (`weight → reps → RPE → next set`)
- Rest timer capsule is implemented:
  - Auto-starts on set completion
  - Non-modal countdown attached to workout screen
  - Inline `-15s / +15s / Skip` controls
- Finish workout flow is implemented:
  - Explicit **Finish Workout** action in `ActiveWorkoutView`
  - Empty-workout guardrail confirmation before saving zero-completion sessions
  - Persists `Workout.completedAt` + `Workout.durationSeconds`
  - Shows facts-first summary (`Duration`, `Completed sets`, `Logged volume`, timing)
- History list is implemented (trust-first scanability):
  - SwiftData-backed **Completed** and **In Progress** sections
  - Row metrics in fixed order: date/time, duration, completed sets, logged volume
  - Explicit status chips + subtle in-progress visual distinction
  - Monospaced/aligned numeric metrics for fast scanning
- Workout detail is implemented (read-only provenance + disclosure):
  - Drill-in from History rows to inspect logged exercises/sets
  - Preserves logged exercise + set order and completion state from saved workout data
  - Reuses facts-first summary framing (duration, completed sets, logged volume)
  - Includes provenance disclosure (`Source`, `Last updated`, and explicit volume formula)

## What’s Next

_Last updated: **2026-02-20**_

- No active **NEXT (BQ-...)** ticket is currently queued in `BUILD-QUEUE.md`.
- Runtime build verification once full Xcode toolchain is active (`xcode-select` currently points to CommandLineTools).

(See: `BUILD-QUEUE.md` and `DEV-LOG.md`.)

## UI/UX Inspiration (Living)

Reference products and patterns to borrow/adapt (not copy):

- Strong — ultra-fast logging ergonomics, clear set-entry flow
- Hevy — polished modern visual style, social/progress cues
- Fitbod — suggestion framing and guidance language
- Apple Health / Fitness — trust-forward data presentation and clarity

### Current UX Principles

1. Logging speed over visual novelty
2. One-thumb operation in core flow
3. Progress clarity in under 3 taps
4. AI advice must be specific, testable, and tied to workout history
5. Avoid “magic” coaching claims before reliability telemetry is proven

---

This README is updated by nightly planning and should stay in sync with the repo and `BUILD-QUEUE.md`.
