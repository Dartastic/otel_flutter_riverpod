# otel_flutter_riverpod example

```dart
// example/lib/main.dart

import 'package:dartastic_opentelemetry/dartastic_opentelemetry.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:otel_flutter_riverpod/otel_flutter_riverpod.dart';

class Counter extends Notifier<int> {
  @override
  int build() => 0;

  void increment() => state++;
}

final counterProvider =
    NotifierProvider<Counter, int>(Counter.new, name: 'counter');

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. Bring up OTel before runApp — the observer captures a Tracer
  //    reference at construction time.
  await OTel.initialize(serviceName: 'riverpod-demo');

  // 2. OTelProviderScope = ProviderScope + OTelRiverpodObserver.
  //    Every provider lifecycle event on the root container now
  //    emits a span.
  runApp(const OTelProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(home: CounterPage());
  }
}

class CounterPage extends ConsumerWidget {
  const CounterPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // ✨ Span on first watch: `provider.added:counter`
    final count = ref.watch(counterProvider);

    return Scaffold(
      body: Center(child: Text('$count')),
      floatingActionButton: FloatingActionButton(
        // ✨ Span on each update: `provider.updated:counter`
        onPressed: () => ref.read(counterProvider.notifier).increment(),
        child: const Icon(Icons.add),
      ),
    );
  }
}
```

## Combining with your own observers

Your observers see events first, then OTel:

```dart
runApp(
  OTelProviderScope(
    observers: [MyDevToolsObserver()],
    child: const MyApp(),
  ),
);
```

## Customizing the OTel observer

```dart
runApp(
  OTelProviderScope(
    otelObserver: OTelRiverpodObserver(
      recordValues: true,
      valueAttributeMaxLength: 128,
    ),
    child: const MyApp(),
  ),
);
```

Need `overrides` or other `ProviderScope` arguments? Use a plain
`ProviderScope` with `observers: [OTelRiverpodObserver()]` instead —
this widget is only the one-line on-switch.
