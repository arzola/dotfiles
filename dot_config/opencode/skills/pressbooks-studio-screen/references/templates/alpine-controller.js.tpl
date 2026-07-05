// TEMPLATE: add to assets/src/scripts/studio.js
//
// Replace <Name> and <name>. Register inside the existing
// `Alpine.start()` boot block, alongside other Alpine.data() calls.
//
// In the screen view, mount with:
//   <section class="mc-<name>" x-data="mcStudio<Name>()" x-cloak> ... </section>
//
// [x-cloak] CSS hides the element until Alpine initialises — prevents FOUC.

Alpine.data('mcStudio<Name>', () => ({
    // ---- state ---------------------------------------------------------
    items: [],
    loading: false,
    error: null,

    // ---- lifecycle -----------------------------------------------------
    async init() {
        await this.fetchItems();
    },

    // ---- actions -------------------------------------------------------
    async fetchItems() {
        this.loading = true;
        this.error = null;

        try {
            const res = await fetch(
                `${window.mcWizard.restUrl}mc/v1/<resource>`,
                {
                    headers: { 'X-WP-Nonce': window.mcWizard.nonce },
                    credentials: 'same-origin',
                },
            );

            if (!res.ok) {
                throw new Error(`HTTP ${res.status}`);
            }

            this.items = await res.json();
        } catch (err) {
            this.error = err.message;
        } finally {
            this.loading = false;
        }
    },
}));
