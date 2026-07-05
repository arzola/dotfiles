# Approval gate

Run this **after** Phase A is complete and **before** any Phase B work.

## Pre-flight reminder

Before posting the gate prompt, confirm to the user (one line):

> If `npm run watch` isn't already running in another terminal, start it
> now — Vite HMR will reflect any tweaks instantly.

## The gate prompt

Post this verbatim (filling in the bracketed bits):

```
🚦 Phase A complete. Approval gate.

Screen: mc-studio-<name>
URL: <wp-admin URL the user should visit>

Components extracted (new in this screen):
  - studio::components.<a>
  - studio::components.<b>

Components reused (already existed):
  - studio::partials.<x>
  - studio::components.<y>

Tokens added:
  - --studio-<token>: <value>   ← <reason>

Tokens reused (no additions): <count>

Icons added: <count or "none">

Files touched in Phase A:
  - src/Studio/StudioRouter.php
  - src/Studio/StudioMenuProvider.php
  - resources/views/studio/screens/<name>.blade.php
  - resources/views/studio/components/<…>.blade.php   (× N)
  - assets/src/styles/studio.css
  - resources/views/studio/partials/icon.blade.php    (if any new icons)

Please open the URL, compare to the prototype, and reply with:
  - "approved" to start Phase B (data wiring + tests), OR
  - a list of specific visual diffs to address in Phase A.
```

## When the user replies with diffs

Stay in Phase A. Iterate on:
- CSS in `assets/src/styles/studio.css`
- Component partial markup
- The screen view's composition
- Fixture content (if data shape is masking a visual issue)

Do **not** touch view models, REST, Alpine, or tests during gate iteration.

After each iteration round, repost the gate prompt with updated counts
and the diff that was addressed called out.

## When the user replies with approval

Open `phase-b-wire-it-up.md` and start at B1. Acknowledge the approval
in your first Phase B message ("Approval received — starting B1.") so
the transition is visible in the conversation log.

## Anti-patterns

- ❌ Skipping the gate because the screen "is small"
- ❌ Posting a hand-wavy summary instead of the structured prompt
- ❌ Asking "should I continue?" instead of asking for explicit approval
- ❌ Starting Phase B "speculatively" while waiting for approval
- ❌ Skipping the `npm run watch` reminder
