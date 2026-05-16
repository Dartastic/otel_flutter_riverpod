# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.1.0-beta.1] - 2026-05-16

### Added

- `OTelProviderScope` — a `ProviderScope` that auto-installs an
  `OTelRiverpodObserver` on the root container. The observer is
  built once in `initState` so it survives widget rebuilds.
- Re-exports `OTelRiverpodObserver` and `RiverpodSemantics` from
  `dartastic_riverpod_otel` so Flutter apps only need one dependency
  on the Pro Riverpod integration.
- Targets `flutter_riverpod: ^3.0.0`.
