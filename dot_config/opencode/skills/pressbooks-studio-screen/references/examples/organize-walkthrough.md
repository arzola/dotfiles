# Worked example: porting `organize.jsx` → `mc-studio-organize`

This is the canonical end-to-end log for using this skill. The
`mc-studio-organize` slug already exists as a placeholder; we're
replacing it with the real screen built from
`docs/microcredentials-exploration/project/organize.jsx`.

Read this once before invoking the skill against any other prototype —
it shows what "good" looks like at every step.

---

## Setup

- **Slug:** `mc-studio-organize` (already registered as placeholder)
- **Context:** Course (per-MC tool)
- **Group:** `'course'`
- **Source:** `organize.jsx`, `Microcredentials - Organize.html`, relevant chunks of `styles.css`

Pre-flight: user runs `npm run watch` in another terminal.

---

## Phase A

### A1 — Context
Read `docs/studio/AGENTS.md`, `adding-a-screen.md`, `css-and-icons.md`.
Confirmed: course-context, group `'course'`, position `10` already in use
by the placeholder — keep that position when replacing.

### A2 — Prototype
Read `organize.jsx` end-to-end. Component tree top-down:

1. `<Frame>` — sidebar + main (chrome — already exists, ignore)
2. `<PageHeader>` — eyebrow ("Course") + title ("Organize") + actions
3. `<ModuleList>` — vertical stack of `<ModuleRow3>`
4. Per row: grip handle + checkbox + title + meta pill + status pill + ellipsis menu
5. Nested lessons under each module (chevron expand)
6. `<AddBar>` at bottom — "+ Add module"

Distinct visual primitives found:
- `StatusPill` (atom)
- `Checkbox` (atom)
- `IconBtn` for ellipsis (atom)
- `MetaPill` for "3 lessons" (atom)
- `PageHeader` (molecule)
- `UnitRow` for module + lesson (molecule, variant by `kind`)
- `AddBar` (molecule)

### A3 — DRY gates

**Components:** none of the 7 exist yet. Extract all to `studio::components.*`.

**Tokens:** prototype uses teal status backgrounds + neutral row surfaces.
Mapped to existing `--pb-teal-10` / `--pb-teal-90` / `--studio-surface`
/ `--studio-border` per `token-mapping.md`. Two new tokens justified:
- `--studio-list-row-bg` (recurs across module + lesson rows)
- `--studio-list-row-bg-hover` (recurs)

Both reference `--pb-neutral-*` primitives.

**Icons:** prototype uses grip, chevron-down, ellipsis-vertical, plus.
Grep `icon.blade.php`: chevron-down + plus exist. Add 2 `@case`s for
`dashicons-grip` and `dashicons-ellipsis-vertical` (heroicons-style 24×24).

Update `component-catalog.md` (7 components → "extracted in organize")
and `token-mapping.md` (2 token rows).

### A4 — Register screen with fixtures

The screen is already in the router + menu (it's a placeholder). Diff:
- `StudioRouter`: change `view: 'studio::screens.placeholder'` → `'studio::screens.organize'` (verify what the current placeholder registration looks like)
- `StudioMenuProvider`: no change (item already declared correctly)
- `resources/views/studio/screens/organize.blade.php`: delete placeholder include, write real screen with `@php $fixtures = [...]; @endphp` containing 3 modules × 2-4 lessons each.

### A5 — CSS

Add new section to `studio.css`:
```css
/* Organize */
.mc-organize { ... }
.mc-organize__header { ... }
.mc-organize__list { ... }
```
~60 lines. All token-based. New tokens added in the existing token
block at the top of the file, NOT inside the Organize section.

Run `composer test && composer lint` → green.

---

## 🚦 Approval gate

Post the structured gate prompt from `approval-gate.md`. URL is the
course subsite's `wp-admin/admin.php?page=mc-studio-organize`.

User reviews. Two iteration rounds:
- "Status pills are slightly too dark" → tweak `--pb-teal-10` use to `--pb-teal-05`
- "Hover state on rows is missing" → add `:hover` rule using `--studio-list-row-bg-hover`

Reposted gate. User: "approved."

---

## Phase B

### B1 — View model

Create `src/Studio/Screens/OrganizeViewModel.php`. `build()` returns
`['header' => [...], 'modules' => [...]]` matching fixture keys.
Real impl: `WP_Query` for `mc_module` ordered by menu_order, with
attached `mc_lesson` children. Returns shaped array.

Replace `@php $fixtures = ...` block with:
```blade
@php
$data = (new \PressbooksMicrocredentials\Studio\Screens\OrganizeViewModel())->build();
@endphp
```
And `$fixtures['…']` → `$data['…']` throughout.

Commit: `feat: shape organize data via view model`.

### B2 — Interactivity decision

Organize lets users reorder modules + toggle status. **Both mutate.**
→ REST + Alpine required.

### B3 — REST controller

`src/Api/OrganizeController.php` with two endpoints:
- `POST /mc/v1/organize/reorder` — body `{ ids: [int] }`, returns new order
- `PATCH /mc/v1/organize/<id>/status` — body `{ status: 'draft'|'published' }`

Capability: `edit_posts` (gated to authors+). Registered via
`OrganizeApiServiceProvider` in `src/Providers/`.

Tests in `tests/Unit/Api/OrganizeControllerTest.php` (5 tests:
routes, perms denied, perms allowed, reorder happy path, status update).

### B4 — Alpine controller

Add `Alpine.data('mcStudioOrganize', () => ({ ... }))` to `studio.js`.
State: `modules`, `dragId`, `loading`. Methods: `onDrop()`, `toggleStatus()`.
Both POST through `window.mcWizard.restUrl` + `window.mcWizard.nonce`.

Add `x-data="mcStudioOrganize()" x-cloak` to the screen's root section
+ `@js(json_encode($data['modules']))` to seed initial state without a
second fetch.

### B5 — Tests

`tests/Unit/Studio/StudioOrganizeViewTest.php`:
- Router resolves `mc-studio-organize` → view `studio::screens.organize`
- Menu provider includes it under group `'course'` with `dashicons-list-view`
- Blade renders with `mc-organize__header` + `mc-organize__list` landmarks
- View output contains the `x-data="mcStudioOrganize()"` attribute

REST tests from B3.

### B6 — Final verification

```bash
composer test                  # 455 + new tests, all green
composer lint                  # green
npm run lint:styles            # green
npm run lint:scripts           # green
npm run build                  # rebuilds dist
git status assets/dist/        # confirm dist files staged
```

Commits in order:
1. `feat: extract organize page chrome` (Phase A — extractions)
2. `feat: render real organize screen` (Phase A — screen view)
3. `feat: style organize screen` (Phase A — CSS)
4. (approval gate iteration commits, squashed or amended)
5. `feat: shape organize data via view model` (B1)
6. `feat: expose organize REST endpoint` (B3)
7. `feat: wire organize alpine controller` (B4)
8. `test: lock mc-studio-organize contract` (B5)
9. `chore: rebuild studio assets` (B6)

---

## Lessons captured

- The teal-10 → teal-05 tweak came up in approval-gate iteration. The
  prototype's exact value didn't map cleanly to either existing token;
  user picked the softer one. **Lesson:** don't agonize over which
  existing token to use in Phase A — defer to the gate.
- Two new tokens for one screen is the right ballpark. >5 means you're
  recreating the prototype's token system instead of mapping into ours.
- The placeholder slug was already in the router + menu — the diff was
  smaller than a from-scratch screen. **Lesson:** check existing
  registrations before adding new ones.
