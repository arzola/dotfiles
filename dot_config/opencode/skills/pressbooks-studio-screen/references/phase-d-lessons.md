# Phase D lessons — patterns and gotchas learned the hard way

These are real findings from Phase D (Studio Organize: CRUD + DnD + skills + keyboard a11y). Each entry is a pattern that, when violated, caused a bug or wasted hours. Read this once before starting Phase B wiring on any non-trivial screen. Re-read the relevant section when you hit a similar problem.

Grouped by where they bite.

---

## Blade / template gotchas

### Attribute-directive precomputation

**Rule:** Never butt `@if` directly against the closing quote of an HTML attribute. Precompute the attribute value via `@php` and emit with `{{ $attr }}`.

**Wrong:**
```blade
<button class="mc-button @if($disabled)mc-button--disabled @endif">
```

**Right:**
```blade
@php
    $btnClass = 'mc-button';
    if ($disabled) {
        $btnClass .= ' mc-button--disabled';
    }
@endphp
<button class="{{ $btnClass }}">
```

**Why:** Mixed-mode emission inside attribute strings is the #1 source of Blade-compiled artifacts that look fine in the browser but are unparseable by `simple_html_dom` and friends used in tests. Precomputation also makes the rendered markup grep-able.

### Blade include namespace convention

**Rule:** Always use namespaced includes: `studio::partials.X`, `studio::components.X`, `studio::screens.X`. Never bare paths.

**Why:** The `studio::` namespace is registered in `BladeServiceProvider` and resolves to `resources/views/studio/`. Bare paths work *until* the resolver order changes and then break silently.

### Component reuse is non-negotiable

**Rule:** If a component exists, use it. Do not fork it because "it's almost what I need." Fix upstream instead.

**Phase D precedent:** Phase C's `mcInlineTitle` Alpine component was almost-but-not-quite right for the Organize screen's inline editing. The temptation was to copy it into a Phase D variant. Correct move was to extend the original to support both call sites. Saved ~200 lines of duplication and one round of bug-fix-twice when the original was patched.

---

## Alpine.js gotchas

### Factory-closure state is not Alpine-tracked

**Rule:** State held in a closure inside an Alpine factory function is not reactive. If the consumer needs to react to changes, mirror the closure state into a reactive property on the component and update both on every mutation.

**Phase D precedent:** The skills-editor stored its pill list in a closure variable. The wizard step-5 dropdown re-rendered from that variable on every keystroke — but Alpine didn't know to re-render because the variable wasn't reactive. Reactive-prop mirror pattern (see `assets/src/scripts/skills-editor.js:139`) is now the precedent. Same fix later needed in `studio.js`.

**Pattern:**
```js
function mySkillsEditor() {
    let _internal = [];  // closure state
    return {
        skills: [],  // reactive mirror — Alpine tracks this
        addSkill(s) {
            _internal.push(s);
            this.skills = [..._internal];  // mirror after every mutation
        },
    };
}
```

### No closure-getters in templates

**Wrong:**
```html
<div x-text="getSomeValue()"></div>
```
when `getSomeValue` reads closure state.

**Right:** Bind to a reactive property; let the component update it.

### No multi-line `@js(...)` inside `x-data=""`

**Rule:** Keep `x-data` expressions simple. If you need multi-line JSON, define a factory function in `studio.js` and call it by name: `x-data="mcMyComponent()"`.

### No bare identifiers that collide with `window` globals

**Rule:** Alpine evaluates expressions in a scope that falls through to `window`. Never name an Alpine property `name`, `event`, `length`, `parent`, etc. Use prefixed names like `_name` or `itemName`.

---

## Drag-and-drop patterns (SortableJS + keyboard)

### DOM-as-truth pattern

**Rule:** The DOM is the source of truth during drag-and-drop. The client never holds a parallel JS model of the tree. On drag start, snapshot `{node, parent, nextSibling}`. On failure, restore via `insertBefore`. On success, refresh derived UI (counts, empty-state placeholders) from the live DOM.

**Why:** Optimistic updates with a parallel model drift from the DOM on edge cases (rapid drags, server failures, cross-parent moves). DOM-as-truth means there's only one tree to be wrong about.

### Drag handle selector

**Rule:** Use `[data-mc-drag-handle]` as the universal handle selector. Tag-agnostic — works for `<button>`, `<span>`, `<div>`.

### DnD endpoint atomicity

**Rule:** Cross-parent moves must wrap the `post_parent` change plus both sibling-list renumbers in a single `START TRANSACTION` / `COMMIT`. Failure path is `ROLLBACK`.

**Phase D precedent:** D.6.1. Without the transaction, a renumber failure between steps left the DB with the new parent assignment but the wrong sibling order — silently corrupting the user's tree. Test with `wpdb` mocked via `$GLOBALS['wpdb'] = Mockery::mock('wpdb')` in `setUp`/unset in `tearDown`.

### Cross-parent edit cap

**Rule:** Cross-parent moves require `edit_post` on the destination parent in addition to the source. Easy to forget.

### Cross-parent position bounds

**Rule:** Cross-parent target position is `0 ≤ position ≤ count` (append allowed). Same-parent reorder is `0 ≤ position ≤ count - 1`. Validate server-side regardless of client clamping.

### SortableJS `onMove` returning `false` cancels drop

**Pattern:** Use `onMove` to block invalid drops (e.g. landing after a trailing `[data-mc-add-*]` button). Add a belt-and-suspenders clamp in `onEnd` for the case where `onMove` was bypassed (rare but happens with rapid drags).

### Keyboard DnD = WAI-ARIA APG pattern

**Rule:** Implement keyboard DnD via a directive (e.g. `mcKeyboardDnd`) that wraps the SortableJS `end*Move` handlers. Lifecycle: Space/Enter pickup; ↑/↓ preview (announce-only, no DOM mutation); ←/→ cross-parent (where supported); Space/Enter drop; Escape cancel.

**Cross-parent hook:** `data-organize-children="lesson|section"` on the SortableJS container declares what type of children it accepts.

**Critical:** During keyboard preview, do NOT mutate the DOM. Only announce. Drop is the sole write moment.

### Aria-live announcement region

**Rule:** Single shared region with `aria-live="polite"`. Place it visually adjacent to the content it announces about, but inside the component's `x-data` root so bindings work.

**Both pointer-DnD failures and keyboard-DnD lifecycle events** announce via the same region. Success path is silent for pointer DnD; keyboard DnD announces every transition.

---

## WordPress / REST gotchas

### `WP_REST_Response` always JSON-encodes

**Rule:** If you need to return raw HTML from a REST endpoint, you must short-circuit via the `rest_pre_serve_request` filter. Returning a string from a `WP_REST_Response` will JSON-encode it (wrapping in quotes, escaping internals).

**Client pattern:** `studioApiFetch(path, {Accept: 'text/html'})` returns raw text when the server cooperates.

### `studioApiFetch` contract

- Body goes in `options.body` (not as second arg).
- Path is relative to `studio/organize/`.
- Namespace is `mc/v1`.
- `Accept: text/html` → raw text response, anything else → parsed JSON.

### Cap-alignment rule for subsite writes

**Rule:** Any write that targets a subsite resource must check `Permissions::canEditMc(get_current_blog_id())` — not the generic `current_user_can('edit_post', $id)` alone. Subsite caps and post caps are separate axes.

### Route-level `permissionCheck` covers the subsite gate

**Pattern:** Register the subsite-membership check at the route level (`permissionCheck` callback). Per-item caps (`edit_post`, etc.) remain in the controller method. This avoids duplicating the subsite check on every endpoint.

### `wp_initialize_site` callback must honor the `WP_Site` arg

**Rule:** Callbacks attached to `wp_initialize_site` receive a `WP_Site` object as the second argument. The callback must `switch_to_blog($site->id)` and `restore_current_blog()` (in `try`/`finally`) — `get_current_blog_id()` will *not* return the new site's ID inside the hook.

**Phase D precedent:** Missing this caused new-MC creation to silently fail to provision per-site tables (`wp_<id>_mc_skill_assignments`), then 500 on first Studio load.

### Migration ordering on `admin_init`

**Rule:** `MigrationRunner::runNetwork` and `runForSite` must hook `admin_init` at priority **3** — after caps registration (priority 1) and before `StudioGate` (priority 5). The default priority 10 is too late.

---

## CSS / Vite gotchas

### Studio shell strips wp-admin CSS

**Rule:** Studio pages do not load WordPress core stylesheets. Any wp-admin utility class your markup references (`.screen-reader-text`, `.button`, etc.) must be defined locally in `studio.css`.

**Phase D precedent:** Keyboard DnD announcements rendered as visible black text because `.screen-reader-text` wasn't defined locally.

### Vite manifest discipline

**Rule:** Only files listed as inputs in `vite.config.js`'s `input{}` object get hashed outputs in `assets/dist/`. Calling `Assets::getAssetUrl()` with a source path that isn't an input returns a 404 path silently.

**Two valid options for a CSS file used by a screen:**
1. Add to `vite.config.js` inputs.
2. Import from a JS entry (`import '../styles/my-screen.css'`) so Vite bundles it into the existing JS entry's CSS output.

**Don't:** call `wp_enqueue_style()` with a hardcoded `assets/dist/...` path. Always go through `Assets::getAssetUrl()` so the manifest stays the source of truth.

### `assets/dist/` Vite hash churn — don't stage

**Rule:** Every dev rebuild produces new content-hashed filenames. These churn constantly during `npm run watch`. Do not `git add assets/dist/` during normal development. Only commit dist artifacts at release time and only if your distribution flow requires them.

### Focus token

**Rule:** Use `var(--studio-focus-ring)` for focus-visible outlines. Never define a new focus color per-component.

---

## i18n preference

### Per-type fully-translated literals over `sprintf`

**Rule:** When you have N types and a templated string, prefer N fully-translated literals over one `sprintf` with placeholders.

**Wrong:**
```php
sprintf(__('Add %s', 'pressbooks-microcredentials'), $type);
```
**Right:**
```php
match ($type) {
    'module' => __('Add module', 'pressbooks-microcredentials'),
    'lesson' => __('Add lesson', 'pressbooks-microcredentials'),
    'section' => __('Add section', 'pressbooks-microcredentials'),
};
```

**Why:** Translators need full context. "Add %s" with a noun token is ambiguous and frequently mistranslated (gender agreement, word order). The exception is aria-labels containing dynamic user data (titles, counts) where `sprintf` is unavoidable.

---

## Testing patterns

### wpdb mock pattern

**Rule:** In tests that touch `$wpdb`, set up in `setUp` and tear down explicitly:

```php
protected function setUp(): void
{
    parent::setUp();
    $GLOBALS['wpdb'] = Mockery::mock('wpdb');
}

protected function tearDown(): void
{
    unset($GLOBALS['wpdb']);
    parent::tearDown();
}
```

### Brain Monkey gotchas

- **Don't mix `Functions\expect()` and `Functions\stubs()` for the same function.** Pick one per test method. Mixing causes the expectation to silently lose to the stub.
- **`__()` returns its first argument by default** under Brain Monkey. You usually don't need to stub it.

### Testability over `final`

**Rule:** Drop `final` from injected view models and controllers. The marginal correctness benefit of `final` isn't worth the test-mocking pain.

---

## Workflow patterns

### Boy-scout cleanup is bounded

**Rule:** Touch only what your bucket explicitly authorizes. If you find DRY violations or dead code outside your bucket, log them as deferred. The exception is *adjacent* cleanup that's discovered while editing the same file — that counts as boy-scout and ships in-bucket.

### Pre-production rule: tear down dead code

**Rule:** While the plugin is pre-production, prefer *deleting* dead code over documenting or fixing it. Leaves a smaller surface for the next maintainer to learn.

**Phase D precedent:** `MenuServiceProvider::enqueueFonts()` was loading a non-existent file path (404 silently). Two options: (A) add `fonts.css` to Vite inputs, (B) delete the method because the bundle was already loading via JS import. Chose B. Smaller surface area.

### Edit-tool safety

**Rule:** After any deletion-style edit, verify the next commit's `git diff --stat` actually shows the deletion. Matching context blocks can silently re-insert lines that look removed in the editor preview.

**Phase D precedent:** A "remove `enqueueFonts` method" edit removed the method body but the `static::addAction(...)` registration line survived because the surrounding context matched in two places. Resulted in a fatal `TypeError` on next page load. Fixup commit needed. Now: always check the diff stat after deletion edits.

### SDD ceremony scaling

**Rule:** Scale Sprint Driven Development ceremony to the work:
- **Full ceremony** (spec doc + writing-plans + TDD + two-stage review): new features, new APIs, anything user-visible.
- **Skip spec-doc + writing-plans**: pure mechanical refactors with obvious scope.
- **Skip TDD**: pure UX wiring where the test would just assert "the element exists" (user opt-in only).

The skip is a deliberate choice, not a default. Document the choice in the commit message.

### Spec-divergence rule

**Rule:** Before coding any task in a plan, validate the plan against the current code. If structural divergence is found (a class was renamed, an API contract changed, a file moved), amend the plan first. Coding against a stale plan compounds the divergence.

### Bucket-close discipline

**This is the most important workflow rule.** Every multi-bucket phase ends with a dedicated bucket-close bucket that contains: REST doc update, AGENTS.md update, OPEN-QUESTIONS.md population, and clean-checkout verification. See `docs/studio/AGENTS.md` § "Phase closure" for the full convention and rationalization counters.

**A phase is code-complete when the last feature bucket lands. A phase is delivery-complete only after the closing bucket.** These are different things. Do not skip the closing bucket.

---

## Header / page-action conventions

### `mc-page__actions` is for Preview + Publish

**Rule:** The page header's `.mc-page__actions` slot holds "Preview" and "Publish" buttons (Publish disabled in pre-production). Type-creating actions ("Add module", "Add lesson") live in `.mc-addbar`, not in the header.

### Success UX

**Rule:** Pointer DnD success is silent (the visual move is the affordance). Failures announce via the shared aria-live region. Keyboard DnD announces every transition (pickup, preview, drop, cancel) via the same region — keyboard users need the audio feedback that pointer users get visually.

### Focus-on-create UX

**Rule:** After creating a new item via REST, defer the focus-the-title-input click via `requestAnimationFrame` so Alpine's `MutationObserver` has time to wire `mcInlineTitle` on the freshly-inserted node.

---

## CPT mapping (Organize-specific, may apply to similar tree screens)

| Prototype name | Real CPT |
|---|---|
| `mc-unit` | `mc_module` |
| `mc-module` | `mc_lesson` |
| `mc-lesson` | `mc_section` |

Variant 2 of the prototype is authoritative. Earlier variants are reference-only.

---

## When to add to this file

Add an entry here when:
- A bug bit you that would have been preventable with a one-sentence rule
- A pattern emerges across 2+ buckets
- You catch yourself rationalizing past a previous lesson

Don't add:
- One-off bugs with no general rule
- Things already covered in `docs/studio/AGENTS.md` (link there instead)
- Speculative "we might want to" rules — only document what actually bit
