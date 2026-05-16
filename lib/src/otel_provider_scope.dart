// Licensed under the Apache License, Version 2.0
// Copyright 2025, Mindful Software LLC, All rights reserved.

import 'package:dartastic_opentelemetry/dartastic_opentelemetry.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:otel_riverpod/otel_riverpod.dart';

/// A `ProviderScope` that auto-installs an [OTelRiverpodObserver].
///
/// Drop-in for the one-line case:
///
/// ```dart
/// void main() async {
///   WidgetsFlutterBinding.ensureInitialized();
///   await OTel.initialize(serviceName: 'my-app');
///   runApp(const OTelProviderScope(child: MyApp()));
/// }
/// ```
///
/// Need to combine with your own observers? Pass them via [observers]
/// — they run before the OTel observer.
///
/// Want full control over the OTel observer (custom tracer,
/// `recordValues: true`, etc.)? Construct one yourself and pass it
/// via [otelObserver].
///
/// **If you also need `overrides` or other `ProviderScope` arguments,
/// just use `ProviderScope` directly with `observers: [OTelRiverpodObserver()]`.**
/// This widget is a convenience for the common "just turn it on" case.
class OTelProviderScope extends StatefulWidget {
  /// Creates a `ProviderScope` with an [OTelRiverpodObserver] already
  /// installed.
  const OTelProviderScope({
    required this.child,
    this.otelObserver,
    this.observers,
    super.key,
  });

  /// The widget below this in the tree.
  final Widget child;

  /// Custom OTel observer. Defaults to `OTelRiverpodObserver()` (which
  /// in turn defaults to `OTel.tracer('otel_riverpod')`).
  ///
  /// `OTel.initialize()` must have run before this widget is built,
  /// because the observer captures a [Tracer] reference at construction
  /// time.
  final OTelRiverpodObserver? otelObserver;

  /// Additional observers to install. The OTel observer is appended
  /// to this list, so your observers see events first.
  final List<ProviderObserver>? observers;

  @override
  State<OTelProviderScope> createState() => _OTelProviderScopeState();
}

class _OTelProviderScopeState extends State<OTelProviderScope> {
  // Build the observer list once in initState so a rebuild of this
  // widget doesn't allocate a fresh observer — and so the
  // observer-list identity stays stable for ProviderScope.
  late final List<ProviderObserver> _observers = [
    if (widget.observers != null) ...widget.observers!,
    widget.otelObserver ?? OTelRiverpodObserver(),
  ];

  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      observers: _observers,
      child: widget.child,
    );
  }
}
