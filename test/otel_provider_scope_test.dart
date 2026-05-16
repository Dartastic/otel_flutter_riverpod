// Licensed under the Apache License, Version 2.0
// Copyright 2025, Mindful Software LLC, All rights reserved.

import 'package:dartastic_opentelemetry/dartastic_opentelemetry.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:otel_flutter_riverpod/otel_flutter_riverpod.dart';

class _MemorySpanExporter implements SpanExporter {
  final List<Span> spans = [];
  bool _shutdown = false;

  @override
  Future<void> export(List<Span> s) async {
    if (_shutdown) return;
    spans.addAll(s);
  }

  @override
  Future<void> forceFlush() async {}

  @override
  Future<void> shutdown() async {
    _shutdown = true;
  }
}

/// A no-op observer that just counts callbacks so we can assert that
/// user-provided observers are still invoked when wrapped by
/// [OTelProviderScope].
final class _CountingObserver extends ProviderObserver {
  int adds = 0;

  @override
  void didAddProvider(ProviderObserverContext context, Object? value) {
    adds++;
  }
}

void main() {
  group('OTelProviderScope', () {
    late _MemorySpanExporter exporter;

    setUp(() async {
      await OTel.reset();
      exporter = _MemorySpanExporter();
      await OTel.initialize(
        serviceName: 'flutter-riverpod-otel-test',
        detectPlatformResources: false,
        spanProcessor: SimpleSpanProcessor(exporter),
      );
    });

    tearDown(() async {
      await OTel.shutdown();
      await OTel.reset();
    });

    testWidgets('installs the OTel observer on the root container',
        (tester) async {
      final probe = Provider<int>((_) => 1, name: 'probe');

      await tester.pumpWidget(
        OTelProviderScope(
          child: Consumer(
            builder: (context, ref, _) {
              ref.watch(probe);
              return const SizedBox.shrink();
            },
          ),
        ),
      );

      // The observer fires synchronously during the first build, but
      // we let one frame settle so any post-frame callbacks complete.
      await tester.pump();

      expect(
        exporter.spans.any((s) => s.name == 'provider.added:probe'),
        isTrue,
      );
    });

    testWidgets('custom observers fire alongside the OTel observer',
        (tester) async {
      final counter = _CountingObserver();
      final probe = Provider<int>((_) => 1, name: 'probe');

      await tester.pumpWidget(
        OTelProviderScope(
          observers: [counter],
          child: Consumer(
            builder: (context, ref, _) {
              ref.watch(probe);
              return const SizedBox.shrink();
            },
          ),
        ),
      );
      await tester.pump();

      expect(counter.adds, equals(1));
      expect(
        exporter.spans.any((s) => s.name == 'provider.added:probe'),
        isTrue,
      );
    });

    testWidgets('respects an explicit otelObserver override', (tester) async {
      final probe = Provider<String>(
        (_) => 'this string is longer than the cap',
        name: 'probe',
      );

      await tester.pumpWidget(
        OTelProviderScope(
          otelObserver: OTelRiverpodObserver(
            recordValues: true,
            valueAttributeMaxLength: 4,
          ),
          child: Consumer(
            builder: (context, ref, _) {
              ref.watch(probe);
              return const SizedBox.shrink();
            },
          ),
        ),
      );
      await tester.pump();

      final added = exporter.spans.singleWhere(
        (s) => s.name == 'provider.added:probe',
      );
      final attrs = {for (final a in added.attributes.toList()) a.key: a.value};
      // recordValues was on, so we expect the clipped value.
      expect(attrs['riverpod.value'], endsWith('…'));
      final v = attrs['riverpod.value']! as String;
      expect(v.length, equals(5)); // 4 + ellipsis
    });
  });
}
