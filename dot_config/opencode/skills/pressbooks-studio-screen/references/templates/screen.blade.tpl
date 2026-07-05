{{-- TEMPLATE: resources/views/studio/screens/<name>.blade.php
     Replace `<name>` and `<Name>` everywhere. Delete this comment block.
     This is Phase A output — fixtures inline. B1 replaces them with $data.
--}}

@php
// PHASE A FIXTURES — replace in B1.
$fixtures = [
    'header' => [
        'eyebrow' => __('Course', 'pressbooks-microcredentials'),
        'title' => __('<Name>', 'pressbooks-microcredentials'),
    ],
    'items' => [
        // Shape mirrors what the view model in B1 will produce.
        ['id' => 1, 'title' => 'Example item one', 'status' => 'published'],
        ['id' => 2, 'title' => 'Example item two', 'status' => 'draft'],
    ],
];
@endphp

<header class="mc-<name>__header">
    <p class="mc-<name>__eyebrow">{{ $fixtures['header']['eyebrow'] }}</p>
    <h1 class="mc-<name>__title">{{ $fixtures['header']['title'] }}</h1>
</header>

<section class="mc-<name>__body" aria-label="{{ __('<Name> content', 'pressbooks-microcredentials') }}">
    @foreach ($fixtures['items'] as $item)
        @include('studio::components.unit-row', [
            'id' => $item['id'],
            'title' => $item['title'],
            'status' => $item['status'],
        ])
    @endforeach

    @include('studio::components.add-bar', [
        'label' => __('Add item', 'pressbooks-microcredentials'),
    ])
</section>
