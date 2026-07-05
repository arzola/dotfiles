<?php
/**
 * TEMPLATE: src/Studio/Screens/<Name>ViewModel.php
 *
 * Replace <Name> and <name> everywhere. Delete this header comment.
 *
 * Convention: keys in build()'s return array MUST match the keys the
 * Phase A `$fixtures` array used in the Blade view. That way, B1's diff
 * is purely "where data comes from" — never "how data is shaped".
 */

declare(strict_types=1);

namespace PressbooksMicrocredentials\Studio\Screens;

/**
 * View model for the mc-studio-<name> screen.
 *
 * Shapes data into the array the Blade view expects. No echoing, no
 * rendering, no wp_die. Pure data shaping.
 */
final class <Name>ViewModel
{
    /**
     * @return array{
     *     header: array{eyebrow: string, title: string},
     *     items: list<array{id: int, title: string, status: string}>,
     * }
     */
    public function build(): array
    {
        return [
            'header' => [
                'eyebrow' => __('Course', 'pressbooks-microcredentials'),
                'title' => __('<Name>', 'pressbooks-microcredentials'),
            ],
            'items' => $this->loadItems(),
        ];
    }

    /**
     * @return list<array{id: int, title: string, status: string}>
     */
    private function loadItems(): array
    {
        // TODO: real data source (WP_Query, Eloquent, REST call to other site).
        // Until then, return [] so the view degrades to its empty state.
        return [];
    }
}
