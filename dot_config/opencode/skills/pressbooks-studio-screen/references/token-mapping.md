# Token mapping

Shared cache of prototype CSS values → existing Studio tokens. Consult
this in Gate 2 of `dry-check.md` before deciding to add a new token.

**Source of truth:** the token block at the top of
`assets/src/styles/studio.css`. If a token below is stale, that file
wins — update this file to match.

---

## Layer convention

- `--pb-*` — brand primitives. Raw color stops, base scale. Stable.
- `--studio-*` — chrome semantics. Surfaces, spacing scale, radii,
  shadows, typography. Composes from `--pb-*` via `var()`.

New tokens go in the right layer. Screen-specific tokens
(`--studio-organize-*`) are an anti-pattern — generalize the name.

---

## Color — known mappings

Prototype `styles.css` uses a teal-leaning palette aligned with Pressbooks brand.

| Prototype value | Existing token | Notes |
|---|---|---|
| Surface white / page bg | `--studio-surface` | use as the default surface |
| Muted surface | `--studio-surface-muted` | what `.studio-main` already uses |
| Body text | `--pb-neutral-90` or `--studio-text-strong` | check the actual token name in `studio.css` |
| Secondary text | `--pb-neutral-70` | for ledes, hints |
| Border / hairline | `--studio-border` | hairlines, dividers |
| Brand teal (action) | `--pb-teal-60` | primary buttons, links |
| Brand teal soft (chip bg) | `--pb-teal-10` | status chip bg, soft surfaces |
| Brand teal deep (chip text) | `--pb-teal-90` | status chip text |
| Danger | `--pb-red-60` (verify) | destructive actions |

> **Verify before using.** Open `assets/src/styles/studio.css` and grep
> for the exact token name — names above are best-known but the file is
> the source of truth.

## Spacing — known mappings

| Prototype value | Existing token |
|---|---|
| 4px | `--studio-space-1` |
| 8px | `--studio-space-2` |
| 12px | `--studio-space-3` |
| 16px | `--studio-space-4` |
| 20px | `--studio-space-5` |
| 24px | `--studio-space-6` |
| 32px | `--studio-space-8` |

(Confirm scale by grepping `--studio-space-` in `studio.css` — if the
existing scale skips numbers, follow it.)

## Radius

| Prototype value | Existing token |
|---|---|
| 6px / sm | `--studio-radius-sm` |
| 10px / md | `--studio-radius-md` |
| 14px / lg | `--studio-radius-lg` |
| 9999 (pill) | `--studio-radius-pill` (or `9999px` if no token — but verify) |

## Font

| Prototype | Existing token |
|---|---|
| Sans body | `--studio-font-family` |
| Body size | `--studio-font-md` |
| Small / meta | `--studio-font-sm` |
| Section heading | `--studio-font-lg` |
| Page heading (h1) | `--studio-font-xl` (verify) |

---

## Adding a row

When a screen needs a value not in this table:

1. Run Gate 2 of `dry-check.md`.
2. If a new token is justified, add it to the right layer in
   `studio.css` first.
3. Then add a row here:
   ```
   prototype `<value>` → `--studio-<name>` — <reason> — first used in <screen>
   ```
4. If you reused an existing token, optionally append a row noting the
   mapping so the next screen finds it instantly.

## Anti-patterns

| Don't | Do |
|------|-----|
| `--studio-organize-row-bg` | `--studio-list-row-bg` (general name) |
| Add a token used once | Reuse the closest existing one |
| Add `--studio-teal-1`, `--studio-teal-2` … | Reference `--pb-teal-*` directly via `var()` |
| Inline `#0aa` in a screen section | Use a token, even if you have to add it |
| Inline `padding: 18px` | Snap to the spacing scale; if the prototype literally needs 18, justify and add `--studio-space-4-5` or pick `--studio-space-4` |
