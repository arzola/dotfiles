# Phase A — UI first

Goal: a routable Studio screen that renders the prototype's layout
faithfully, using extracted/reused components and existing tokens, with
**hardcoded fixture data**. No view model. No REST. No Alpine logic.

Exit criterion: user opens the slug in their browser, compares against
the prototype HTML, and approves.

---

## A1 — Read context

Read these three files in order. They are short. Do not skim.

1. `docs/studio/AGENTS.md`
2. `docs/studio/adding-a-screen.md`
3. `docs/studio/css-and-icons.md`

If you've read them in a previous turn, re-read the screen mount
contract and the MenuContext decision table.

Identify:
- The slug (`mc-studio-<name>`)
- The MenuContext (`Root` cross-MC or `Course` per-MC)
- The group (`'primary'` or `'course'`)
- The position (next free integer in the chosen group)

---

## A2 — Read prototype

The handoff bundle lives in `docs/microcredentials-exploration/project/`.
Per the bundle's `README.md`, **read source files directly — do not try
to render them in a browser**.

For your chosen page, read:

1. The `.jsx` file end-to-end (component tree, what each region does)
2. The matching `Microcredentials - <Name>.html` export (final rendered structure)
3. Any obviously-relevant section of `styles.css` (search by class name)

Output (mental model, not a file): a list of every distinct visual
component the page uses, top to bottom. For each, note:
- Prototype name (e.g., `StatusPill`, `ModuleRow3`)
- Where it appears (header / list / row / footer / sidebar)
- Whether it's a simple atom or a composition

This list drives A3.

---

## A3 — DRY gates (extract only what's missing)

For each item from A2, run the appropriate DRY gate from
`references/dry-check.md`:

- **Components** → check `resources/views/studio/components/` and
  `partials/`. Extract only if absent. Document a 1-line reason in the
  partial header comment.
- **Tokens** → check `assets/src/styles/studio.css` token block. Reuse;
  add only when the value recurs ≥2× AND is semantically distinct.
- **Icons** → check `resources/views/studio/partials/icon.blade.php`.
  Add a `@case` only for genuinely new glyphs.

After each addition, **update `references/component-catalog.md` and
`references/token-mapping.md`** so the next screen finds it.

Component partials follow the skeleton at
`references/templates/component.blade.tpl`. Each takes props via
`@include('studio::components.<name>', ['prop' => value])`.

Class naming: `.mc-<component>` + `.mc-<component>__<element>` +
`.mc-<component>--<modifier>` (BEM-ish, matches prototypes).

---

## A4 — Register screen with inline fixtures

This is three small files. Do all three in the same commit.

### A4.1 — Router registration

Edit `src/Studio/StudioRouter.php` (`registerDefaults()`). Add:

```php
$this->register(new StudioScreen(
    slug: 'mc-studio-<name>',
    title: 'Human title',
    view: 'studio::screens.<name>',
    contexts: [MenuContext::Course], // or the cross-MC trio
));
```

### A4.2 — Menu item

Edit `src/Studio/StudioMenuProvider.php` (`registerDefaults()`). Add a
`MenuItem::make()` to the `registerMany([...])` array. Follow the exact
pattern of existing items (`src/Studio/StudioMenuProvider.php:74` for a
course-context example).

Required calls: `->title()`, `->icon()`, `->position()`, `->group()`,
`->contexts()`, `->studioEligible(true)`, `->studioScreen('<same slug>')`.

If the slug replaces a placeholder, **remove the placeholder's
registration in the same edit** — never leave two registrations for the
same slug.

### A4.3 — Blade view with inline fixtures

Create `resources/views/studio/screens/<name>.blade.php`. Use the
skeleton at `references/templates/screen.blade.tpl`.

Put fixtures at the top inside a `@php` block, exactly like:

```blade
@php
// PHASE A FIXTURES — replace in B1.
$fixtures = [
    'modules' => [
        ['id' => 1, 'title' => 'Foundations of personal finance', 'lessons' => 3, 'status' => 'published'],
        ['id' => 2, 'title' => 'Budgeting in practice', 'lessons' => 5, 'status' => 'draft'],
    ],
];
@endphp
```

Then compose the page from extracted/existing components. Reference the
fixtures as `$fixtures['…']`.

**Cardinal rule:** the file must NOT contain `<main>`, `<html>`, `<body>`,
or any chrome — those live in `resources/views/studio/layout.blade.php`.

---

## A5 — CSS block

Edit `assets/src/styles/studio.css`. Add one section under a clear
banner comment:

```css
/* ============================================================================
   <screen name>
   ============================================================================ */

.mc-<screen> { … }
.mc-<screen>__<element> { … }
```

Rules:
- Tokens only (`--pb-*` / `--studio-*`). No hex / no px literals.
- Group by component, not by element type.
- Keep selectors flat — no `>`, `+`, `~` unless the prototype demands it.
- If a value isn't in any existing token, run the token DRY gate. If
  justified, add the token in the appropriate token section first, then
  reference it here.

For HMR, the user runs `npm run watch` in a separate terminal — your
edits hit the browser instantly. **Do not** run `npm run build` in
Phase A; that's a B6 concern.

---

## End of Phase A

Run `composer test && composer lint` — the existing suite must still
pass. (You haven't added tests yet; that's B5.)

Now go to `references/approval-gate.md` and post the exact gate prompt.
**Do not proceed to Phase B until the user replies with approval.**
