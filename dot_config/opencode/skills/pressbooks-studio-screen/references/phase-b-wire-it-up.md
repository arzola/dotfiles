# Phase B — Wire it up

**Entry condition: the user has explicitly approved Phase A.** If you're
reading this and the user hasn't said "approved", "looks good", "ship
it", or similar — stop. Re-open the approval gate.

Goal: replace fixtures with real data; add interactivity only if needed;
lock the contract with tests; verify the build.

---

## B1 — View model

Create `src/Studio/Screens/<Name>ViewModel.php` using
`references/templates/view-model.php.tpl`.

Responsibilities:
- Fetch and shape data the screen needs.
- Return an array (or DTO) with the **same keys** the Blade view used
  for `$fixtures` so the only diff is "where data comes from", not "how
  data is shaped".
- No echoing, no `wp_die`, no rendering.

Wiring: the screen view gets the view model's output passed in. Two
options:

1. **View model in the screen view's `@php` block.** Cheap, no
   framework changes. Use this unless multiple screens share the same
   data shape.
   ```blade
   @php
   $data = (new \PressbooksMicrocredentials\Studio\Screens\OrganizeViewModel())->build();
   @endphp
   ```
2. **View model called from the renderer.** Only if `StudioRenderer`
   needs to know about it (e.g., for caching, or for sharing with the
   layout). Requires touching `StudioRenderer::render()` — flag this in
   the commit message and add a test for the new payload.

Replace every `$fixtures['…']` reference in the Blade view with
`$data['…']`. Delete the `PHASE A FIXTURES` block and its comment.

---

## B2 — Decide interactivity

Use this table:

| Need | Path |
|------|------|
| Read-only, current site only | Stop. No REST, no Alpine. Skip to B5. |
| Read-only but cross-site (e.g. lists MCs from other subsites) | REST GET endpoint. Continue to B3. |
| Any mutation (create / update / delete / reorder) | REST + Alpine. Continue to B3. |
| Pure visual state (expand / collapse / tab switch with no persistence) | Alpine only. Skip B3, go to B4. |

Write your decision down in the commit message for B1 so reviewers know
why subsequent commits exist (or don't).

---

## B3 — REST controller (if needed)

Follow `docs/studio/rest-controllers.md`. Use
`references/templates/rest-controller.php.tpl` as the starting point.

Required:
- Namespace: `mc/v1` (existing convention)
- Capability check via `permission_callback`
- Nonce via the `mcWizard.nonce` already localized by `StudioAssets`
- Schema in `get_item_schema()`
- One controller class per resource, registered through the appropriate
  `*ApiServiceProvider` in `src/Providers/`

Tests go in `tests/Unit/Api/<Name>ControllerTest.php`.

---

## B4 — Alpine controller (if needed)

Add a factory function to `assets/src/scripts/studio.js`:

```js
Alpine.data('mcStudio<Name>', () => ({
    init() { /* … */ },
    /* state + methods */
}));
```

Wire it into the screen view by adding `x-data="mcStudio<Name>()"` on
the screen's root element, plus `[x-cloak]` to prevent FOUC.

If the controller calls REST: use `window.mcWizard.restUrl` +
`window.mcWizard.nonce`. Both are localized in `StudioAssets`.

Use `references/templates/alpine-controller.js.tpl` as the starting
point.

---

## B5 — Tests (always)

Three minimum tests; add a fourth if B3 happened.

1. **Router contract** — add an assertion to
   `tests/Unit/Studio/StudioRouterTest.php` (or new file) that
   `StudioRouter::resolve('mc-studio-<name>')` returns a screen with
   slug, title, view, and contexts matching what you registered.

2. **Menu contract** — extend
   `tests/Unit/Studio/StudioMenuProviderTest.php` so the new slug
   appears in `studioEligible()` with the right group + icon + position
   + contexts.

3. **View renders + landmarks** — copy
   `tests/Unit/Studio/StudioDefaultScreensViewTest.php` as a starting
   point, or extend it. Assert:
   - The Blade view renders without throwing.
   - The expected `<h1>` text is present.
   - At least 2 distinguishing landmarks are present (e.g., a section
     class, a component class, a critical action label).

4. **REST tests** — only if B3 happened. See
   `references/templates/rest-test.php.tpl`.

Anti-patterns:
- Don't assert every CSS class — that's brittle.
- Don't assert exact HTML — that's brittle.
- Do assert structural landmarks and key user-visible strings.

---

## B6 — Final verification

Run, in order, and confirm green:

```bash
composer test
composer lint
npm run lint:styles
npm run lint:scripts
npm run build
```

Check the dist artifacts are tracked:

```bash
git status assets/dist/
```

If `assets/dist/studio-*.css` or `studio-*.js` changed, stage them.

---

## Commits

Phase B's commits, in order:

1. `feat: shape <name> data via view model`
2. `feat: expose <name> REST endpoint` *(if B3)*
3. `feat: wire <name> alpine controller` *(if B4)*
4. `test: lock mc-studio-<name> contract`
5. `chore: rebuild studio assets`

---

## Done

The user can now use the screen with real data. Update
`references/component-catalog.md` and `references/token-mapping.md` one
final time with anything you extracted in Phase A but didn't think to
log at the time.
