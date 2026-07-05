<?php
/**
 * TEMPLATE: src/Api/<Name>Controller.php
 *
 * Replace <Name>, <name>, <resource>. Delete this header.
 *
 * REST conventions (see docs/studio/rest-controllers.md):
 *  - Namespace: mc/v1
 *  - Capability check via permission_callback (NEVER trust the client)
 *  - Nonce: rest_cookie_check_errors handles it for cookie-authed users
 *           when the request carries X-WP-Nonce; the Studio frontend
 *           passes window.mcWizard.nonce automatically
 *  - Define get_item_schema() and reference it in register_routes()
 *  - Register the controller in the matching *ApiServiceProvider in
 *    src/Providers/, not from here
 */

declare(strict_types=1);

namespace PressbooksMicrocredentials\Api;

use WP_Error;
use WP_REST_Controller;
use WP_REST_Request;
use WP_REST_Response;
use WP_REST_Server;

final class <Name>Controller extends WP_REST_Controller
{
    public function __construct()
    {
        $this->namespace = 'mc/v1';
        $this->rest_base = '<resource>';
    }

    public function register_routes(): void
    {
        register_rest_route($this->namespace, '/'.$this->rest_base, [
            [
                'methods' => WP_REST_Server::READABLE,
                'callback' => [$this, 'get_items'],
                'permission_callback' => [$this, 'get_items_permissions_check'],
                'args' => $this->get_collection_params(),
            ],
            'schema' => [$this, 'get_public_item_schema'],
        ]);
    }

    public function get_items_permissions_check($request): bool|WP_Error
    {
        if (! current_user_can('edit_posts')) {
            return new WP_Error(
                'mc_rest_forbidden',
                __('You are not allowed to view this resource.', 'pressbooks-microcredentials'),
                ['status' => 403],
            );
        }

        return true;
    }

    public function get_items($request): WP_REST_Response
    {
        $items = []; // TODO: load from DB / service

        return rest_ensure_response($items);
    }

    public function get_item_schema(): array
    {
        if ($this->schema !== null) {
            return $this->add_additional_fields_schema($this->schema);
        }

        $this->schema = [
            '$schema' => 'http://json-schema.org/draft-04/schema#',
            'title' => '<name>',
            'type' => 'object',
            'properties' => [
                'id' => [
                    'description' => __('Unique identifier for the resource.', 'pressbooks-microcredentials'),
                    'type' => 'integer',
                    'context' => ['view', 'edit'],
                    'readonly' => true,
                ],
                'title' => [
                    'description' => __('Human-readable title.', 'pressbooks-microcredentials'),
                    'type' => 'string',
                    'context' => ['view', 'edit'],
                ],
            ],
        ];

        return $this->add_additional_fields_schema($this->schema);
    }
}
