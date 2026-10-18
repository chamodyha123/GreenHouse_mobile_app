# GreenPlan Cleanup Report

## Status

Cleanup Batch 1 is complete. Twelve verified obsolete source files were deleted. No asset, dependency, Firebase configuration, Firestore rule, cache, or cloud data was changed.

## Actual changes

- Added `docs/GREENPLAN_CLEANUP_AUDIT.md`.
- Added this report.
- Added `docs/GREENPLAN_FUTURE_MODULES.md`.
- Deleted `lib/controller/account_controller.dart`.
- Deleted `lib/controller/auth_controller.dart`.
- Deleted `lib/controller/chat_controller.dart`.
- Deleted `lib/controller/navigation_controller.dart`.
- Deleted `lib/controller/onboarding_controller.dart`.
- Deleted `lib/controller/privacy_setting_controller.dart`.
- Deleted `lib/controller/theme_controller.dart`.
- Deleted `lib/models/chat_model.dart`.
- Deleted `lib/models/message_model.dart`.
- Deleted `lib/models/user_model.dart`.
- Deleted `lib/utils/helper_functions.dart`.
- Deleted `lib/utils/device/device_utility.dart`.

All 12 approved files were deleted. No approved file was skipped: import, symbol, routing, DI, test, platform, and code-generation checks found no active dependency. The remaining `lib/controller/`, `lib/models/`, and `lib/utils/device/` directories were empty and were removed with their files.

## Preserved reusable foundation

Firebase initialization and project configuration for `smart-gebere-d230e`, Firebase Authentication, Firestore, Hive offline storage, connectivity handling, layered Auth/Farmer domain code, weather services, disease diagnosis, AI advice, crop/task history, profile/record models, analytics, localization, settings, and existing tests remain unchanged.

## Dependency changes

None. `pubspec.yaml` and `pubspec.lock` are unchanged. The audit identified packages to review later but did not remove any package in this batch.

## Firebase verification

`firebase.json`, `firestore.rules`, `lib/firebase_options.dart`, and `android/app/google-services.json` remain present and retain the existing project configuration. No Firebase CLI operation, rules deployment, collection migration, or user-data operation occurred.

## Validation

The requested commands were started after deletion. `flutter pub get` completed successfully. `flutter analyze` and `flutter test` were both started, but produced no diagnostics and did not complete; the parallel attempts were stopped after extended inactivity. A standalone retry of `flutter analyze` also remained silent and was stopped. The environment therefore did not produce a usable analyzer or test result. This is a validation-environment limitation, not evidence of a cleanup failure.

### Validation results

- `flutter pub get`: passed (exit code 0). It reported one discontinued package and 115 newer versions incompatible with current constraints; no upgrade was performed.
- `flutter analyze`: no result. The process stayed silent beyond the normal startup window in both parallel and standalone attempts, then was stopped. No analyzer error was reported.
- `flutter test`: no result. It stayed silent while the concurrent analyzer held Flutter's tool lock, then was stopped. No test failure was reported.

The analyzer/test runs need to be repeated in an interactive or otherwise healthy Flutter environment before a clean validation baseline can be claimed.

## Known remaining issues

- Active UI and layered domain/repository implementations overlap.
- Multiple weather and Gemini client implementations overlap.
- Cleanup Batch 1 removed the unreachable legacy `chewata`/GetX controller, model, and utility files; the remaining application source has no `chewata` or GetX import.
- The `.env` file is bundled as a Flutter asset, exposing private API credentials in production builds.
- Firestore collection names use both uppercase and lowercase farmer roots.
- Product and UI PDF contents were not text-extracted in this environment; Figma was not accessed.
