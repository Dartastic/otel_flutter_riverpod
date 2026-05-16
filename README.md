# otel_flutter_riverpod

Flutter overlay for [`otel_riverpod`](../otel_riverpod/README.md).

Two things:

1. **Re-exports** the core `OTelRiverpodObserver` + `RiverpodSemantics`
   so a Flutter app only needs one dependency on the Dartastic-Pro
   Riverpod integration.
2. **`OTelProviderScope`** — a `ProviderScope` that auto-installs the
   OTel observer:

   ```dart
   void main() async {
     WidgetsFlutterBinding.ensureInitialized();
     await OTel.initialize(serviceName: 'my-app');
     runApp(const OTelProviderScope(child: MyApp()));
   }
   ```

That's the entire surface area — the actual instrumentation lives in
the core package; this one is a Flutter-shaped on-switch.

## Choosing this vs. plain `ProviderScope`

Use `OTelProviderScope` when you just want telemetry on:

```dart
runApp(const OTelProviderScope(child: MyApp()));
```

Use a plain `ProviderScope` directly if you also need `overrides`,
custom `retry`, or other `ProviderScope` arguments — the OTel
observer drops in just as easily:

```dart
runApp(
  ProviderScope(
    overrides: [...],
    observers: [OTelRiverpodObserver()],
    child: const MyApp(),
  ),
);
```

## Combining with your own observers

Pass them via `observers:` and the OTel observer is appended:

```dart
OTelProviderScope(
  observers: [MyAuditObserver(), MyDevToolsObserver()],
  child: const MyApp(),
)
```

Your observers see events first, then OTel.

## Configuration

To customize the OTel observer (record value content, change tracer,
suppress updates, …), construct it explicitly and pass it via
`otelObserver:`:

```dart
OTelProviderScope(
  otelObserver: OTelRiverpodObserver(
    recordValues: true,
    valueAttributeMaxLength: 128,
  ),
  child: const MyApp(),
)
```

See [`otel_riverpod`](../otel_riverpod/README.md)
for the full attribute reference and the span shape the observer
produces.

## Caveats

- `OTel.initialize()` must run **before** `runApp` — the observer
  captures a `Tracer` reference at construction time.
- The observer is created once in `initState` and reused across
  rebuilds. Like all `ProviderScope` instances, this widget should
  live at the app root; the underlying `ProviderContainer` outlives
  any individual rebuild.

## License

Apache 2.0 — see `LICENSE`.
