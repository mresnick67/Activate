# Activate

AI-powered iOS workout tracker focused on reliable logging, data portability, and practical coaching insights.

- Platform: iOS 17+
- Stack: SwiftUI, SwiftData, HealthKit, OpenAI API (MVP)
- Architecture: local-first MVP (backend deferred to V2)

## What’s Complete

_Last updated: 2026-02-18_

- Foundation scaffold is in place (`Activate/` app project structure).
- Core SwiftData models are implemented (`Workout`, `Exercise`, `ExerciseTemplate`, `WorkoutSet`, `UserProfile`).
- App shell is implemented (Today / History / Analytics / Settings).
- Design system baseline is in place (dark-mode semantic theme).
- Exercise seed system is implemented (211 bundled exercises + first-launch seeding).
- Start Workout flow is implemented (blank/template entry + exercise picker with search/filter).

## What’s Next

- Set logging UI (weight/reps/RPE add/edit/delete)
- Rest timer (preset + auto-start on set completion)
- Finish workout + save flow (duration/volume summary + persistence)
- Workout history list
- Runtime build verification once full Xcode toolchain is active

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

This README is intended to be updated by nightly planning with objective progress deltas.
