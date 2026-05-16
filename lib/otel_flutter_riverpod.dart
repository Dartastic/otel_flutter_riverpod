// Licensed under the Apache License, Version 2.0
// Copyright 2025, Mindful Software LLC, All rights reserved.

/// Flutter overlay for `otel_riverpod`.
///
/// Re-exports the core observer + [RiverpodSemantics] enum and adds
/// [OTelProviderScope] for one-line installation in a Flutter app.
library;

export 'package:otel_riverpod/otel_riverpod.dart';

export 'src/otel_provider_scope.dart';
