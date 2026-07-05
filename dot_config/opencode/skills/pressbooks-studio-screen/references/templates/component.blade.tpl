{{--
    TEMPLATE: resources/views/studio/components/<component-name>.blade.php

    Each component partial is invoked via:
        @include('studio::components.<component-name>', ['prop' => value])

    Required Blade comment header explains WHY this component exists and
    which prototype it came from. This is mandatory per dry-check.md Gate 1.
--}}

{{--
    mc-<component-name>
    Reason: <why no existing partial fit; one sentence>.
    Source: <prototype-file>.jsx (component name in JSX)
    Props:
        - <propA> (string, required)        — <one-line description>
        - <propB> (string, optional, default 'default') — <variant explainer>
--}}

@php
$propA = $propA ?? '';
$propB = $propB ?? 'default';
$classes = trim('mc-<component-name> mc-<component-name>--'.$propB);
@endphp

<div class="{{ $classes }}">
    {{-- Content — keep markup minimal; lean on CSS for variants. --}}
    {{ $propA }}
</div>
