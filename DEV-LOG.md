# Activate — Dev Log

Keep entries factual and anchored to commits/files.

---

## 2026-02-19 — Nightly Build Run (02:10 ET)

**Phase:** BQ-007 Set logging UI

**What changed**
- Replaced placeholder set rows in `LiftKit/Views/Workout/ActiveWorkoutView.swift` with real inline logging rows.
- Added new `LiftKit/Views/Workout/WorkoutSetRowView.swift`:
  - weight / reps / RPE inline numeric entry,
  - completion toggle,
  - visible invalid-input state,
  - "Last" ghost values + one-tap **Repeat**.
- Added keyboard toolbar flow in active workout (`Next` / `Done`) with focus progression:
  - `weight → reps → RPE → next set`.
- Added set management affordances:
  - inline **Add Set** per exercise group,
  - swipe-to-delete set rows.
- Expanded `LiftKit/ViewModels/WorkoutViewModel.swift` with helper methods for:
  - set completion timestamp coherence,
  - add/delete/reindex sets,
  - shared persistence saves.
- Regenerated project with `xcodegen generate` so new source file is included in `LiftKit.xcodeproj`.

**Queue update**
- Marked **BQ-007** DONE in `BUILD-QUEUE.md` with implementation notes.
- Promoted **BQ-008** as top NEXT ticket.

**Verification**
- `xcodegen generate` completed successfully ✅
- Runtime `xcodebuild` verification still blocked on host Xcode selection (`CommandLineTools` active) ⚠️

**Next up**
- BQ-008 Rest timer capsule (auto-start on completion, inline controls)
- BQ-009 Finish workout + save flow

## 2026-02-19 — Nightly planning (01:30 ET)

**Repo status**
- Latest commit: `d5a2e0f` (docs: sync README with current planning status)
- Working tree changes: none
- Untracked: `UIUX-INSPIRATION.md`

**What changed tonight (planning artifacts)**
- Created missing planning files expected by nightly loop:
  - `BUILD-QUEUE.md`
  - `DEV-PLAN.md`
  - `DEV-LOG.md` (this file)
- Synced README’s "What’s Complete" and "What’s Next" to match actual repo state and `BUILD-QUEUE.md`.
  - Corrected mismatches (e.g., missing models previously claimed; default exercise count is 91).

**Current blockers**
- None detected in code; primary gap is UI work for set entry (placeholder rows in `ActiveWorkoutView`).

**Next up**
- BQ-007 Set logging UI (inline weight/reps/RPE + completion + ergonomic focus progression)
- BQ-008 Rest timer capsule (auto-start on completion; quick +/- controls)
