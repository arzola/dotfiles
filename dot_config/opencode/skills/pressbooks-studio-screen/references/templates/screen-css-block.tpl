/* TEMPLATE: append to assets/src/styles/studio.css
 *
 * Replace <name> with the screen's slug suffix (e.g. "organize").
 * Tokens only — no hex, no px literals. Run Gate 2 of dry-check.md
 * before adding any new token.
 */

/* ============================================================================
   <Name>
   ============================================================================ */

.mc-<name> {
    /* root container — usually a flex/grid column */
    display: flex;
    flex-direction: column;
    gap: var(--studio-space-6);
}

.mc-<name>__header {
    display: flex;
    flex-direction: column;
    gap: var(--studio-space-2);
}

.mc-<name>__eyebrow {
    color: var(--pb-neutral-70);
    font-size: var(--studio-font-sm);
    font-weight: 600;
    letter-spacing: 0.04em;
    text-transform: uppercase;
}

.mc-<name>__title {
    margin: 0;
    font-size: var(--studio-font-xl);
    color: var(--studio-text-strong);
}

.mc-<name>__body {
    display: flex;
    flex-direction: column;
    gap: var(--studio-space-3);
}
