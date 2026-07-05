# TEMPLATE: add this to src/Studio/StudioMenuProvider.php
# inside registerDefaults() → $this->registry->registerMany([ ... ])
#
# Replace <name>, <Title>, <dashicon>, <position>, <group>, <contexts>.
# `position` must be unique within its group. `group` is 'primary' or 'course'.
# `<contexts>` is a local var defined at top of the method:
#   $rootContexts = [MenuContext::Network, MenuContext::Root, MenuContext::Course];
#   $courseContexts = [MenuContext::Course];

MenuItem::make('mc-studio-<name>')
    ->title(__('<Title>', 'pressbooks-microcredentials'))
    ->icon('<dashicon>')                  // e.g. 'dashicons-list-view'; add to icon.blade.php if missing
    ->position(<position>)                // unique ordinal within the group
    ->group('<group>')                    // 'primary' (cross-MC) or 'course' (per-MC)
    ->contexts(<contexts>)                // $rootContexts or $courseContexts
    ->studioEligible(true)                // REQUIRED — Studio renderer ignores items without this
    ->studioScreen('mc-studio-<name>'),   // MUST equal ->slug


# AND add to src/Studio/StudioRouter.php registerDefaults() (real file location;
# the docs/studio/adding-a-screen.md path is the canonical reference):

$this->register(new StudioScreen(
    slug: 'mc-studio-<name>',
    title: '<Title>',
    view: 'studio::screens.<name>',
    contexts: <contexts>,                 // same as menu item
));
