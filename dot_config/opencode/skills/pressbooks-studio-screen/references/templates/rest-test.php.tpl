<?php
/**
 * TEMPLATE: tests/Unit/Api/<Name>ControllerTest.php
 *
 * Replace <Name>, <name>, <resource>. Delete this header.
 */

declare(strict_types=1);

namespace PressbooksMicrocredentials\Tests\Unit\Api;

use Brain\Monkey\Functions;
use PressbooksMicrocredentials\Api\<Name>Controller;
use PressbooksMicrocredentials\Tests\TestCase;

class <Name>ControllerTest extends TestCase
{
    protected function setUp(): void
    {
        parent::setUp();
        Functions\when('__')->returnArg();
        Functions\when('rest_ensure_response')->returnArg();
    }

    public function test_registers_route_under_mc_v1(): void
    {
        Functions\expect('register_rest_route')
            ->once()
            ->with(
                'mc/v1',
                '/<resource>',
                \Mockery::type('array'),
            );

        (new <Name>Controller())->register_routes();
    }

    public function test_get_items_permissions_check_denies_without_cap(): void
    {
        Functions\when('current_user_can')->justReturn(false);

        $controller = new <Name>Controller();
        $result = $controller->get_items_permissions_check(null);

        $this->assertInstanceOf(\WP_Error::class, $result);
    }

    public function test_get_items_permissions_check_allows_with_cap(): void
    {
        Functions\when('current_user_can')->justReturn(true);

        $controller = new <Name>Controller();
        $result = $controller->get_items_permissions_check(null);

        $this->assertTrue($result);
    }

    public function test_get_items_returns_array(): void
    {
        $controller = new <Name>Controller();
        $items = $controller->get_items(null);

        $this->assertIsArray($items);
    }

    public function test_schema_has_required_properties(): void
    {
        $schema = (new <Name>Controller())->get_item_schema();

        $this->assertArrayHasKey('properties', $schema);
        $this->assertArrayHasKey('id', $schema['properties']);
        $this->assertArrayHasKey('title', $schema['properties']);
    }
}
