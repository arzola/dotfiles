# Component catalog

Shared cache of prototype primitives → target Studio component paths.
Update this every time a screen extracts something new, so the next
screen finds it via Gate 1 of `dry-check.md`.

**Status legend:**
- `existing` — already in the repo before any Studio screen work
- `extracted` — added by a Studio screen build (note which screen)
- `not yet extracted` — seen in a prototype, no real implementation yet
- `deferred` — intentionally postponed (e.g., needs Lexical)

---

## Atoms

| Prototype symbol | Status | Target path | Props | Source / used in |
|---|---|---|---|---|
| `Icon.*` | existing | `studio::partials.icon` | `icon` (dashicons-*) | every screen |
| `StatusPill` | not yet extracted | `studio::components.status-pill` | `status` (draft/published/archived), `size?` | `organize.jsx`, `editor-v2.jsx` |
| `StatusToggle` | not yet extracted | `studio::components.status-toggle` | `status`, `onToggle` (Alpine) | `organize.jsx` |
| `Checkbox` | not yet extracted | `studio::components.checkbox` | `id`, `checked`, `label` | `organize.jsx` |
| `IconBtn` | not yet extracted | `studio::components.icon-btn` | `icon`, `label`, `variant?` (ghost/solid) | most prototypes |
| `MetaPill` / `Duration` | not yet extracted | `studio::components.meta-pill` | `icon?`, `value`, `unit?` | `organize.jsx`, `learner.jsx` |
| `Eyebrow` | not yet extracted | `studio::components.eyebrow` | `text` | `editor-v2.jsx`, `details.jsx` |

## Chrome partials (existing, reuse only)

| Partial | Path | Notes |
|---|---|---|
| Topbar | `studio::partials.topbar` | owned by chrome — do not modify from a screen |
| Sidebar | `studio::partials.sidebar` | owned by chrome |
| User menu | `studio::partials.user-menu` | owned by chrome |
| Wizard | `studio::partials.wizard` | overlay, see `docs/studio/adding-an-overlay.md` |
| Icon | `studio::partials.icon` | extend via Gate 3 of `dry-check.md` only |

## Molecules

| Prototype symbol | Status | Target path | Notes |
|---|---|---|---|
| `PageHeader` | not yet extracted | `studio::components.page-header` | eyebrow + title + actions slot |
| `AddBar` | not yet extracted | `studio::components.add-bar` | bottom-of-list "+ Add" CTA |
| `ModuleRow` / `LessonRow` / `SectionRow` | not yet extracted | `studio::components.unit-row` | single component, `kind` prop (module/lesson/section) |
| `SkillsChips` | not yet extracted | `studio::components.skills-chips` | input + chip list |
| `PeopleList` | not yet extracted | `studio::components.people-list` | avatar rows + add CTA |
| `NavPane` (editor side rail) | not yet extracted | `studio::components.nav-pane` | editor-only; respects `navPos` Alpine state |
| `TabStrip` | not yet extracted | `studio::components.tab-strip` | content / settings switch |
| `Eyebrow` row + title block | not yet extracted | `studio::components.edit-head` | editor-only header |

## Deferred

| Prototype symbol | Status | Reason |
|---|---|---|
| `Toolbar` (Lexical) | deferred | needs Lexical vendoring — future `pressbooks-studio-lexical` skill |
| `SettingsDrawer` / `SettingsInline` | deferred | tied to editor shell; defer until first editor screen |
| `mc-rt-block` (math/table/image embeds) | deferred | Lexical node renderers, not Blade partials |

---

## Adding a row

When you extract or extend a component in a real screen build:

1. Move the row from "not yet extracted" to "extracted in `<screen>`".
2. Fill in the actual props list.
3. If you extended an existing component instead of creating a new one,
   add the new prop to its row and note "extended for `<screen>`".
4. Commit this file alongside the screen's commits.
