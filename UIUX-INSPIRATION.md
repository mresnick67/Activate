# Activate — UI/UX Inspiration Log

Last updated: 2026-02-19
Owner: UI/UX Inspiration Worker

## Current sprint focus
- **Primary:** Task #7 Set logging UI (speed + low-error entry)
- **Next:** Task #8 Rest timer (auto-trigger, low-friction control)
- **Trust thread:** Task #9 Finish summary must present verifiable facts before AI interpretation

## External signal check (today)
- Re-checked official Strong and Hevy docs/pages plus store listings.
- Net: no paradigm shift; strongest near-term win is still **faster set logging + clearer trust cues**.
- Rotated emphasis today toward **rest timer ergonomics** and **AI explanation framing**.

## Inspiration references and patterns (current)

### 1) Strong — inline set logging with minimal ceremony
**Reference:** Strong Help Center (“How do I perform a workout with Strong?”), Strong store descriptions/reviews (previous-session context, fast set completion).

**Pattern to borrow:**
- Add set, swipe-to-delete, checkbox-to-complete in one continuous list flow.
- Keep set entry inline (no modal per set).
- Surface previous performance context in-row so users don’t recall from memory.

**Why this matters now:**
- `ActiveWorkoutView` currently renders placeholder set rows (`"—"`).
- Task #7 is blocked on exactly this interaction model.

---

### 2) Hevy — rest timer attached to set completion, not detached utilities
**Reference:** Hevy feature pages (“Workout Rest Timer”, “Live Activity”).

**Pattern to borrow:**
- Per-exercise rest defaults.
- Timer auto-start on set completion.
- Quick +/-15s and skip controls without leaving workout screen.
- Timer visibility while phone is locked/other app is open (Live Activity concept for later).

**Why this matters now:**
- Task #8 comes immediately after logging rows.
- If timer control is modal-heavy, logging flow speed collapses.

---

### 3) Apple HIG (Entering Data) — constrain numeric input at the field level
**Reference:** Apple Human Interface Guidelines, Entering Data.

**Pattern to borrow:**
- Numeric-specific input behavior and formatting.
- Input constraints that prevent invalid values early.
- Keep data entry compact and scannable.

**Why this matters now:**
- Weight/reps/RPE are structured numeric fields.
- Preventing bad input up front is faster than post-save correction.

---

### 4) Apple Health/Fitness-style trust framing — facts first, interpretation second
**Reference:** Apple Health/Fitness presentation style + current product principle (“avoid magic coaching claims”).

**Pattern to borrow:**
- Show raw workout facts first (duration, volume, completed sets).
- AI guidance is explicitly derived from visible data.
- Use “based on X” language to ground every recommendation.

**Why this matters now:**
- Task #9 (finish/save summary) should establish trust before AI analysis milestones (Sprint 6).
- Trust framing should be baked in before LLM UI lands.

## Implementation-ready actions (next 24h)

1) **Ship `WorkoutSetRowView` for Task #7 in `ActiveWorkoutView`**
   - Inline fields: `weight`, `reps`, `RPE`, plus completion checkbox.
   - Numeric keyboard + focus progression (`weight -> reps -> RPE -> next set`).
   - Add “last” ghost values (previous session for same exercise/set index) and one-tap “Repeat Last”.

2) **Implement timer capsule for Task #8 (non-modal)**
   - On set checkmark: auto-start per-exercise countdown.
   - Inline controls: `-15s`, `+15s`, `Skip`.
   - Persist default timer on exercise-level metadata so templates can reuse it later.

## Anti-pattern to avoid
- **Do not hide AI logic behind confidence theater** (e.g., generic “Great progress!” with no derivation).
  - If a suggestion cannot cite concrete workout evidence, show it as tentative or don’t show it yet.
