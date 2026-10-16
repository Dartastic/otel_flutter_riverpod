# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.3.1-wip]

### Changed

- README: standard header naming the instrumented library, its supported platforms and project links; pubspec description to match.

## [0.3.0] - 2026-10-11

### Changed

- Requires `dartastic_opentelemetry_api >=1.0.0-rc.4 <1.0.0-rc.5`.
- Requires `otel_riverpod ^0.3.0`, the API-only release.
- **Breaking:** depends on `dartastic_opentelemetry_api` only, no
  longer on the SDK. The application chooses and initializes the
  OpenTelemetry SDK. Parameters and fields typed with SDK classes
  now use the API types (`APITracer`, `APISpan`, `APILogger`, ...);
  SDK instances are still accepted wherever an API type is expected.

## [0.2.0] - 2026-08-10

## [0.1.0-beta.1] - 2026-05-16

### Added

- `OTelProviderScope` — a `ProviderScope` that auto-installs an
  `OTelRiverpodObserver` on the root container. The observer is
  built once in `initState` so it survives widget rebuilds.
- Re-exports `OTelRiverpodObserver` and `RiverpodSemantics` from
  `otel_riverpod` so Flutter apps only need one dependency for
  Riverpod instrumentation.
- Targets `flutter_riverpod: ^3.0.0`.
