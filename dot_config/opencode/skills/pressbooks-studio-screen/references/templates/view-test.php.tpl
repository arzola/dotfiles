<?php
/**
 * TEMPLATE: tests/Unit/Studio/Studio<Name>ViewTest.php
 *
 * Replace <Name> and <name>. Delete this header.
 *
 * Locks the screen's contract: router + menu + Blade renders +
 * landmark assertions. REST tests live in tests/Unit/Api/.
 */

declare(strict_types=1);

namespace PressbooksMicrocredentials\Tests\Unit\Studio;

use Brain\Monkey\Functions;
use PressbooksMicrocredentials\Menu\MenuContext;
use PressbooksMicrocredentials\Menu\MenuItemRegistry;
use PressbooksMicrocredentials\Studio\StudioMenuProvider;
use PressbooksMicrocredentials\Studio\StudioRouter;
use PressbooksMicrocredentials\Tests\TestCase;

class Studio<Name>ViewTest extends TestCase
{
    protected function setUp(): void
    {
        parent::setUp();
        Functions\when('__')->returnArg();
        Functions\when('is_plugin_active')->justReturn(false);
        Functions\when('esc_html')->returnArg();
        Functions\when('esc_attr')->returnArg();
        Functions\when('esc_url')->returnArg();
    }

    public function test_router_resolves_screen(): void
    {
        $router = new StudioRouter();
        $router->registerDefaults();

        $screen = $router->resolve('mc-studio-<name>');

        $this->assertNotNull($screen);
        $this->assertSame('mc-studio-<name>', $screen->slug);
        $this->assertSame('studio::screens.<name>', $screen->view);
        $this->assertContains(MenuContext::Course, $screen->contexts); // adjust per context
    }

    public function test_menu_provider_registers_item(): void
    {
        $registry = new MenuItemRegistry();
        (new StudioMenuProvider($registry))->registerDefaults();

        $slugs = array_map(
            fn ($i) => $i->getSlug(),
            $registry->studioEligible(),
        );

        $this->assertContains('mc-studio-<name>', $slugs);
    }

    public function test_view_renders_with_landmarks(): void
    {
        $blade = $this->makeBlade(); // helper from TestCase, returns Blade instance
        $html = $blade->render('studio::screens.<name>');

        $this->assertStringContainsString('<Name>', $html);          // h1 text
        $this->assertStringContainsString('mc-<name>__header', $html); // structural landmark
        $this->assertStringContainsString('mc-<name>__body', $html);   // structural landmark
    }
}
