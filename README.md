# LiftKit (working name: Activate)

Swift-native iOS workout tracker focused on reliable logging, data portability, and practical coaching insights.

- Platform: iOS 17+
- Stack (current): SwiftUI, SwiftData
- Stack (planned, post-MVP): HealthKit, OpenAI API
- Architecture: local-first MVP (backend deferred to V2)

## What’s Complete

_Last updated: **2026-02-19**_

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

## What’s Next

_Last updated: **2026-02-19**_

- **BQ-008** Rest timer (auto-start on set completion; inline `-15s/+15s/Skip` controls; non-modal).
- **BQ-009** Finish workout + save flow (facts-first summary; persist `completedAt` + duration).
- **BQ-010** Replace History placeholder with real workout list + **BQ-011** workout detail.
- Runtime build verification once full Xcode toolchain is active.

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
