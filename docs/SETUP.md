# Setup

## Prerequisites

- Flutter 3.x and Dart SDK
- A Firebase project (Auth, Firestore, Storage enabled)
- A Google AI Studio (Gemini) API key

## Steps

```bash
flutter pub get
flutter run
```

The project already contains Firebase configuration for `smart-gebere-d230e`.
Run `flutterfire configure` only when you intentionally need to change that
Firebase project or its supported platforms.

Provide the Gemini key through `--dart-define=GEMINI_API_KEY=...` or the config file the app reads (see `lib/core`), depending on the current implementation.

## Quality checks

```bash
flutter analyze
flutter test
```

## Release builds

```bash
flutter build apk --release
flutter build appbundle --release
```
