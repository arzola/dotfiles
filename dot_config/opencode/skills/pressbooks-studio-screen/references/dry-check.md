# DRY gates

Three gates. Run the matching one BEFORE adding any component, token,
or icon to the Studio. Reusing > extending > adding.

The user has explicitly required this discipline. A screen that adds
duplicates of existing primitives will be rejected.

---

## Gate 1 — Component DRY check

Before creating `resources/views/studio/components/<name>.blade.php` or
`resources/views/studio/partials/<name>.blade.php`:

1. **List what exists.** Run:
   ```bash
   ls resources/views/studio/components/ resources/views/studio/partials/
   ```
2. **Search by concept.** Run a grep for the visual idea (not the
   prototype's literal class name). Examples:
   - Status pill / badge / chip → `grep -ri "pill\|badge\|chip" resources/views/studio/`
   - Checkbox → `grep -ri "checkbox" resources/views/studio/`
   - Row with grip handle → `grep -ri "grip\|drag\|handle" resources/views/studio/`
3. **Coverage test.** If an existing partial covers ≥80% of what you
   need:
   - **Extend it.** Add a new prop / slot / variant modifier class.
   - Do NOT clone it under a slightly different name.
4. **Check the catalog.** Read
   `references/component-catalog.md` for any earlier screen that
   already extracted what you need.
5. **If you must create one,** add a leading Blade comment justifying
   why no existing partial fit:
   ```blade
   {{--
       mc-status-pill
       Reason: existing studio::components.* had no status / state
       chip primitive. Extracted from organize.jsx StatusPill.
   --}}
   ```
6. **Update the catalog.** Add a row to
   `references/component-catalog.md` with the new component, the props
   it accepts, and the prototype it came from.

### Red flags

| If you find yourself… | Stop and… |
|----------------------|-----------|
| Naming a new partial `*-v2` or `*-new` | An extension of the original is the right answer. |
| Copy-pasting an existing partial then editing | Extract the variation as a prop instead. |
| Creating one partial per page | Components are reusable by definition. |
| Skipping the grep "because I just searched" | Re-grep. Conventions evolve. |

---

## Gate 2 — Token DRY check

Before adding any `--pb-*` or `--studio-*` token to
`assets/src/styles/studio.css`:

1. **Open the token block** at the top of `studio.css`. Read every
   token in the same family (color / spacing / radius / font).
2. **Find the closest existing value.** If within a tolerance:
   - **Color:** if the existing token is visually indistinguishable
     (ΔE < 2 by eye), reuse.
   - **Spacing:** if the existing token is within ±2px and not used in
     a context where pixel-perfect alignment matters, reuse.
   - **Radius / font-size:** reuse the closest unless the prototype
     deliberately establishes a new scale.
3. **Check the mapping cache.** Read
   `references/token-mapping.md` — earlier screens may have already
   resolved this exact prototype value.
4. **Add a new token only when** ALL of these hold:
   - The value recurs ≥2× in your screen, OR is conceptually distinct
     (e.g., a brand-new semantic role like "warning surface").
   - No existing token is a reasonable substitute.
   - The new token slots into the existing layered convention:
     - `--pb-*` for brand primitives (raw colors, scale)
     - `--studio-*` for chrome semantics (surfaces, spacing scale, …)
     - Compose via reference: `--studio-foo-bg: var(--pb-teal-05);`
5. **Update the mapping.** Add a row to
   `references/token-mapping.md`:
   `prototype value | new token | reason | first used in <screen>`

### Hard rules

- **Never** inline a hex value in a screen's CSS section.
- **Never** inline a px value for spacing.
- New tokens belong in the existing token sections of `studio.css`, not
  scattered into screen sections.
- Token names use kebab-case and the layered prefix
  (`--studio-list-row-bg`, not `--organize-row-bg`).

### Red flags

| If you find yourself… | Stop and… |
|----------------------|-----------|
| Adding `--studio-organize-*` tokens | Either generalize the name or use existing tokens. |
| Adding 10+ tokens for one screen | You're recreating the prototype's token system instead of mapping into ours. |
| Adding a token used once | Reuse the closest existing one. |

---

## Gate 3 — Icon DRY check

Before adding any icon to
`resources/views/studio/partials/icon.blade.php`:

1. **Read every `@case`** in the file. Note both the dashicon key and
   the actual glyph.
2. **Look for variants.** Many "different" icons are the same glyph
   with a rotation or stroke variation. Reuse with CSS, not a new case.
3. **Add a `@case` only for genuinely novel glyphs.** Use the same SVG
   conventions as the existing cases (Heroicons-style, 24×24, 1.5
   stroke).
4. **Never** emit raw `<svg>` from a screen view or a component partial.
   Always go through `@include('studio::partials.icon', ['icon' => 'dashicons-…'])`.

### Red flags

| If you find yourself… | Stop and… |
|----------------------|-----------|
| Writing `<svg>` in a screen | Add an icon case + use the partial. |
| Adding both `chevron-down` and `caret-down` | One is enough; the other is a rotation/variant. |
| Inlining a prototype's icon by URL | Convert to inline SVG following the partial's convention. |

---

## After every DRY decision

Write a one-liner in the commit message that mentions what you reused
vs. added. Example:

```
feat: extract organize page chrome

Reused: studio::partials.icon (existing chevron, ellipsis).
Added: studio::components.status-pill, studio::components.unit-row.
Tokens added: --studio-list-row-bg (recurs across module + lesson rows).
```

This makes review fast and keeps the DRY discipline visible.
