# GreenPlan Phase 1C Audit and GitHub-Readiness Report

## Scope and outcome

This report records the Phase 1C audit and its subsequently approved final
cleanup. Five unreachable legacy utility source files and five unreferenced
root-level screenshots were deleted. No active Flutter feature, declared
Flutter asset, Firebase configuration file, Firestore rule, native application
identifier, package name, or cloud data was changed.

The implementation changes in this phase are limited to user-visible product
branding and the GitHub Actions workflow. The display-only branding now uses
`GreenPlan` in the English UI, Android display label, iOS display name, and web
metadata; package and native identifiers are unchanged. The workflow is now a
non-deploy validation workflow for Flutter 3.47.0. It runs dependency
resolution, analysis, tests with coverage, and a web build. It does not deploy
Firebase Hosting, create Firebase resources, or use production API secrets.

## Inspected areas

- Flutter source, tests, asset declarations, and textual references.
- `lib/utils/constants/` and `lib/utils/link.dart`.
- The five root `photo_*.jpg` files and the two images under `assets/`.
- Display branding across Flutter, Android, iOS, and web configuration.
- The current in-repository localization implementation and settings UI.
- `.gitignore`, `.env`/`.env.example` key names only, `pubspec.yaml`, Firebase
  files, Firestore rules, and the GitHub Actions workflow.
- Existing GreenPlan cleanup and stabilization documentation.

The GreenPlan product proposal was previously available as a DOCX reference.
The supplied PDF specifications were not text-extracted in this environment,
and no Figma source was accessed; this audit does not claim otherwise.

## Legacy cleanup candidates — approval required

| Candidate | Dependency result | Audit finding | Proposed action |
| --- | --- | --- | --- |
| `lib/utils/constants/color.dart` | No source or test use found | Unused legacy visual constants | Delete after approval. |
| `lib/utils/constants/image_strings.dart` | No source or test use found | Unused paths to legacy/missing assets | Delete after approval. |
| `lib/utils/constants/sizes.dart` | No source or test use found | Unused legacy layout constants | Delete after approval. |
| `lib/utils/constants/text_strings.dart` | No source or test use found | Contains unrelated `Chewata` social-app copy | Delete after approval. |
| `lib/utils/link.dart` | No source or test use found | Contains an obsolete `chewata` Realtime Database URL | Delete after approval. |
| `photo_1_2025-02-11_21-45-30.jpg` | No source, test, docs, or declared-asset reference | Screenshot of the legacy disease-detection UI, not a raw sample image | Delete after approval. |
| `photo_2_2025-02-11_21-45-30.jpg` | No source, test, docs, or declared-asset reference | Screenshot of legacy account creation | Delete after approval. |
| `photo_3_2025-02-11_21-45-30.jpg` | No source, test, docs, or declared-asset reference | Screenshot of Ethiopian open-field recommendation UI | Delete after approval. |
| `photo_4_2025-02-11_21-45-30.jpg` | No source, test, docs, or declared-asset reference | Screenshot of an old task/dashboard UI | Delete after approval. |
| `photo_7_2025-02-11_21-45-30.jpg` | No source, test, docs, or declared-asset reference | Screenshot of legacy open-field onboarding | Delete after approval. |

## Final cleanup execution

The previously approved files were deleted after a repeated dependency check
found no reference outside the files themselves or the prior audit records:

- `lib/utils/constants/color.dart`
- `lib/utils/constants/image_strings.dart`
- `lib/utils/constants/sizes.dart`
- `lib/utils/constants/text_strings.dart`
- `lib/utils/link.dart`
- `photo_1_2025-02-11_21-45-30.jpg`
- `photo_2_2025-02-11_21-45-30.jpg`
- `photo_3_2025-02-11_21-45-30.jpg`
- `photo_4_2025-02-11_21-45-30.jpg`
- `photo_7_2025-02-11_21-45-30.jpg`

The root photographs were UI screenshots, not disease-classification training
or reference images. The empty `lib/utils/constants/` directory was removed.

### Preserved assets

- `assets/image_1.jpg` remains in use by
  `lib/task_management/descrition.dart`. It depicts open-field wheat farming,
  so it should be replaced during a future greenhouse UI migration rather than
  removed now.
- `assets/image_2.jpg` has no current textual reference, but depicts a
  diseased leaf being photographed and is potentially reusable for disease
  detection. It is preserved.

## Branding and localization audit

Clearly user-visible legacy branding exists in the splash screen, task page,
settings, privacy text, Android display label, iOS display name, and web
manifest/index metadata. `SmartGebereApp`, `smart_gebere` package imports,
Android package identifiers, iOS bundle identifiers, Firebase project and app
identifiers are implementation identifiers and are intentionally unchanged.

Approved low-risk display-only update performed:

- Changed visible English product names to `GreenPlan` in the splash/task UI,
  English in-repository localization, Android label, iOS
  `CFBundleDisplayName`, web manifest, web title, and web metadata.
- Replaced the splash and English tagline with “Greenhouse planning for Sri
  Lankan growers.”
- Left package and native identifiers unchanged.

The localization system currently supports English, Amharic, and Afaan Oromo,
and settings exposes those choices. It also contains country-specific labels
and units such as `Timad`. Sri Lanka support requires a deliberate migration to
English (`en`), Sinhala (`si`), and Tamil (`ta`) across locale storage,
localized strings, settings, AI prompt language selection, units, geography,
and validation. No translations were invented and no localization framework or
files were removed during this audit.

There is additional Ethiopia-specific operational content in the AI adviser,
weather advice, market prices, yield prediction, farm profile, knowledge base,
phone validation, and documentation. This is functional/product content, not a
safe string-only cleanup; it requires a reviewed GreenPlan domain migration.

## Documentation review

`README.md`, `CHANGELOG.md`, `CONTRIBUTING.md`, `test.md`, and several older
documents under `docs/` still describe Smart Gebere, Ethiopian farming,
Amharic/Oromo support, or obsolete example repository URLs. They should be
rewritten or archived in a separate documentation pass after GreenPlan product
copy and support/contact details are approved. Existing Phase 1 GreenPlan
cleanup, future-modules, and stabilization records remain the authoritative
history for completed work.

## Security and Firebase review

- `.gitignore` excludes `.env`, `.env.*`, signing material, local platform
  configuration, build output, and generated Flutter files; `.env.example` is
  intentionally allowed.
- The app currently loads `.env` as a Flutter asset. Consequently a production
  build can embed third-party API credentials. This remains a high-priority
  design risk, not something removed in this compatibility-preserving phase.
- The immediate migration path is a server-side proxy for generative AI and
  provider APIs, authenticated and rate-limited, followed by removal of client
  secrets from bundled assets. That work needs separate backend/API approval.
- `firebase.json`, `firestore.rules`, `lib/firebase_options.dart`, and platform
  Firebase configuration were inspected but not modified. The Firebase project
  remains `smart-gebere-d230e`; no CLI operation, deployment, collection
  migration, rule change, or cloud-data operation occurred.

## CI readiness

The former workflow was unsafe for a newly connected repository: it pinned an
older Flutter version, made info-level lint messages fatal, used an incorrect
coverage upload path, injected API secrets into builds, and deployed Firebase
Hosting from `main`.

The updated workflow is validation-only:

- Flutter is pinned to the stated local baseline, 3.47.0.
- It analyzes, tests with coverage, and builds web from the repository root.
- It copies only the key-only `.env.example` template for the web-build input.
- It uploads coverage and web build artifacts only.
- It contains no Firebase deployment action, Firebase service-account secret,
  or production API-secret injection.

No repository was initialized, connected, pushed, or otherwise changed outside
the workspace.

## Validation and remaining blockers

After the approved cleanup, `flutter pub get` completed successfully. The
requested commands then ran sequentially: `flutter analyze --no-pub`,
`flutter test --no-pub`, and `flutter build web --no-pub`. Each completed in
this automation environment without emitting diagnostics, so none is recorded
as a successful analyzer, test, or build result. This is the same
Flutter-wrapper limitation previously observed in the workspace.

The previously recorded Phase 1B direct-analyzer baseline was zero errors, 109
warnings, and 921 info messages. The user has additionally reported 57 passing
tests and a successful web build. Those results are retained as historical
context, not substituted for a verified Phase 1C full-validation result.

Before enabling required checks on a new GitHub repository, run the workflow or
the equivalent commands in a healthy Flutter environment and record the actual
CI result. The principal remaining blockers are a reviewed Sri Lankan
localization/content migration, the client-side API-secret architecture, and
the residual warnings and information-level lint backlog.

## Approved and performed changes

- Updated limited English/display metadata from Smart Gebere to GreenPlan.
- Updated `.github/workflows/ci.yml` to validation-only CI.
- Added this audit report.
- Deleted the five approved legacy Chewata utility files.
- Deleted the five approved root-level legacy screenshots.

No other application modules were modified.
