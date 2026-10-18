# GreenPlan Cleanup Audit

## Scope and evidence

This audit began as a read-only review. Cleanup Batch 1 was subsequently approved and executed on the 12 verified legacy files listed below. No other application source, asset, Firebase configuration, dependency, or generated cache was changed.

The GreenPlan project proposal was reviewed. It establishes greenhouse-only planning, layout and planting calculations, weather-based crop advice, disease detection, AI advice, a growth calendar, cost and profit analysis, offline/cloud data, and PDF export as the implementation baseline. The product-specification PDF and UI PDF are available at the supplied download paths, but a usable PDF text extractor was not available in this environment, so their detailed content was not used to make deletion decisions. The Figma prototype was not accessed.

## Active application and dependency graph

The executable path is `lib/main.dart` -> `lib/stream/stream_provider.dart` -> `lib/splash/splash_screen.dart` -> either onboarding/login or `lib/Home/Home.dart`. `Home_Screen` directly imports and navigates to its task, crop, weather, record, profile, knowledge, AI doctor, disease, yield, mapping, settings, and privacy pages.

Firebase is initialized from `lib/firebase_options.dart`; Hive-backed offline storage and connectivity monitoring are initialized before `runApp`. The active UI largely calls Firebase services directly. A second, layered authentication/farmer implementation exists under `lib/features/`, registered by `lib/core/di/injection.dart`, but `setupDependencies()` is not called by `main.dart`. It remains tested and reusable, but is not the active runtime path.

Firestore collection names in current code are mixed: `user_data`, `users`, `Farmers`, `farmers`, and subcollections such as `records` and `disease_results`. The existing rules cover the user and farmer roots. No schema or rules changes are appropriate in this phase.

## Classification

| Classification | Paths | Reason and dependency / planned action |
| --- | --- | --- |
| KEEP | `lib/main.dart`, `lib/firebase_options.dart`, `firebase.json`, `firestore.rules`, `android/app/google-services.json`, platform Firebase configuration | Required startup and Firebase connection to `smart-gebere-d230e`. Do not rename, regenerate, deploy, or migrate. |
| KEEP | `lib/auth/login/login.dart`, `lib/auth/signup/sign_up.dart`, `lib/splash/splash_screen.dart`, `lib/stream/stream_provider.dart`, `lib/onboarding/onboarding_page.dart` | Active authentication and startup flow. Refine UI/route guards later without removing Firebase Auth behavior. |
| REFACTOR LATER | `lib/features/auth/**`, `lib/core/di/injection.dart`, `lib/core/usecases/usecase.dart`, `lib/core/errors/**`, `lib/core/utils/input_validator.dart` | Reusable layered Auth/domain foundation with tests. It duplicates direct Firebase calls in the active login/signup UI and its DI bootstrap is inactive. Make it the single implementation only in a tested migration. |
| REFACTOR LATER | `lib/features/farmer/**` | Crop, field, farmer, and week entities plus repository/use-cases are useful for greenhouse/crop planning. Current fields and the `Farmers` schema need greenhouse adaptation. |
| KEEP | `lib/core/services/offline_storage.dart`, `lib/core/services/connectivity_service.dart`, `lib/core/services/connectivity_{io,web,stub}.dart`, `lib/core/network/network_info.dart`, `lib/core/services/logger_service.dart` | Needed for offline/cloud plans, synchronization, resilient network handling, and diagnostics. Consolidate usage later. |
| REFACTOR LATER | `lib/core/services/weather_service.dart`, `lib/geo_Location/location.dart`, `lib/geo_Location/wetherdata.dart`, `lib/features/weather_advisor/weather_advisor_page.dart` | Weather/location is in GreenPlan scope, but there are multiple API and AI-assisted implementations. Retain until a single weather provider is selected and tested. |
| KEEP | `lib/Disease_page/DiseaseDetection.dart`, `lib/core/models/detection_history.dart` | Active leaf image picking/capture, Gemini abstraction usage, and diagnostic-history concept are directly relevant. Move into `features/disease_detection` later; do not delete. |
| REFACTOR LATER | `lib/features/ai_doctor/ai_crop_doctor_page.dart`, `lib/core/services/ai_reliability.dart` | AI crop advice is required, but currently duplicates Gemini setup and uses a client-bundled secret. Extract a provider-agnostic service and use a backend proxy. |
| REFACTOR LATER | `lib/Home/{created_task,cropdetailpage,expected_event,task_creation,weeklydetailpage}.dart`, `lib/task_management/**`, `lib/scheduling/schedule.dart` | Active crop/task/lifecycle behavior maps to GreenPlan's calendar and reminders. Its open-field wording, `Farmers` structure, and several direct Gemini calls require a safe future migration. |
| REFACTOR LATER | `lib/features/farm_profile/**`, `lib/core/models/farm_profile.dart`, `lib/features/farm_records/**`, `lib/core/models/farm_record.dart` | Reusable profile, records, persistence, analytics, and offline concepts. Rename farm concepts to greenhouse/project only after the data model is agreed. |
| REFACTOR LATER | `lib/features/yield_prediction/**`, `lib/features/market_prices/**`, `lib/core/models/market_price.dart` | Supports the proposed harvest forecast and financial/profit modules, but is not yet the specification's cost/revenue model. |
| REVIEW | `lib/features/field_mapping/field_mapping_page.dart` | The proposal excludes open-field cultivation and does not require maps. It is active in the dashboard, but could be replaced by rectangular greenhouse dimensions. Candidate for deletion only after UI/specification review and approval. |
| REVIEW | `lib/features/knowledge_base/**`, `lib/core/models/knowledge_article.dart`, `lib/core/services/content_service.dart` | Knowledge content can support AI advice and guidance, but current content includes Ethiopian/general-farming data and the service is not wired to the active UI. Preserve until content ownership and Sri Lankan source data are defined. |
| KEEP | `lib/settings/**`, `lib/l10n/**`, `lib/utils/theme/app_theme.dart`, `lib/features/privacy/**` | Settings, localization, theme, and privacy affordances are reusable foundations. Existing Amharic/Oromo data needs later localization review for Sri Lanka. |
| DUPLICATE | Direct Auth UI in `lib/auth/**` versus `lib/features/auth/**` | Both cover sign-up/login/logout/profile data. The direct UI is active; the repository layer is better structured but inactive. Do not merge or delete during cleanup. |
| DUPLICATE | `lib/Disease_page/DiseaseDetection.dart` versus `lib/features/ai_doctor/ai_crop_doctor_page.dart` | Both use Gemini/image-oriented crop diagnosis. Retain both until a feature boundary is chosen: diagnosis from a leaf photo versus chat advice. |
| DUPLICATE | `lib/core/services/weather_service.dart`, `lib/geo_Location/{location,wetherdata}.dart`, and `lib/features/weather_advisor/weather_advisor_page.dart` | All concern weather/location/crop suggestions. Consolidation needs provider, cache, API-key, and test decisions. |
| REMOVED | `lib/controller/{account_controller,auth_controller,chat_controller,navigation_controller,onboarding_controller,privacy_setting_controller,theme_controller}.dart`, `lib/models/{chat_model,message_model,user_model}.dart` | Batch 1: verified no active imports, routing, DI, test, platform, or code-generation references. The controllers depended on legacy `chewata` services and GetX; no GreenPlan logic was preserved there. |
| REMOVED | `lib/utils/helper_functions.dart`, `lib/utils/device/device_utility.dart` | Batch 1: verified unreferenced and dependent on absent GetX. |
| REVIEW | `lib/utils/constants/{color,image_strings,sizes,text_strings}.dart`, `lib/utils/link.dart` | Largely unreferenced utility remnants. They are low-risk cleanup candidates, but must be checked against uncommitted local work before deletion. |
| REVIEW | `assets/image_1.jpg`, `assets/image_2.jpg` | `image_1.jpg` is used by `lib/task_management/descrition.dart`; `image_2.jpg` has no textual reference. Image semantics were not inspected, so neither should be removed yet. |
| REMOVE CANDIDATE | Root `photo_1_2025-02-11_21-45-30.jpg`, `photo_2_2025-02-11_21-45-30.jpg`, `photo_3_2025-02-11_21-45-30.jpg`, `photo_4_2025-02-11_21-45-30.jpg`, `photo_7_2025-02-11_21-45-30.jpg` | They are outside declared Flutter assets and no source/docs reference was found. Inspect visually once before approval; they may be original disease samples. |
| REFACTOR LATER | `README.md`, `CHANGELOG.md`, `CONTRIBUTING.md`, `test.md`, `docs/{README,SETUP,FEATURES,ARCHITECTURE,API_REFERENCE,USER_GUIDE,ENTERPRISE_REVIEW,QUICK_REFERENCE_AM}.md` | These contain Smart Gebere/Ethiopian or legacy product documentation. Replace or archive after the new docs are approved; do not delete historical information yet. |
| KEEP | `test/**`, `.github/workflows/ci.yml`, `analysis_options.yaml`, `.gitignore` | Tests and CI are reusable. Update package/import branding only in a coordinated package rename. `.gitignore` already excludes `.env`, build, signing keys, and generated directories. |

## Dependency audit

Packages in clear use include Firebase Core/Auth/Firestore, dotenv, Hive/Hive Flutter, connectivity_plus, provider, geolocator, HTTP, Gemini, image/file pickers, markdown, charts, UUID, GetIt, dartz, logger, localization, Google Fonts, timeline tiles, and test libraries.

The following have no package import in `lib/` or `test/`: `awesome_dialog`, `hive` (transitively required by `hive_flutter`, so retain), `flutter_image_compress`, `path_provider`, `flutter_secure_storage`, `firebase_crashlytics`, `firebase_analytics`, `mockito`, and `fake_cloud_firestore`. No dependency will be removed until the approved source cleanup has occurred and a fresh dependency scan/tests pass. `get` is imported by legacy files but is missing from `pubspec.yaml`; do not add it because the importing files are removal candidates.

## Security and configuration findings

- `.env` is correctly ignored, but is declared as a Flutter asset and is loaded at startup. Any AI or weather key in it is embedded in compiled clients; Git ignore does not protect it after release.
- The app reads several inconsistent key names (`API_KEY`, `GEMINI_API_KEY`, `OPENWEATHER_API_KEY`, and `apiKeyW`). Do not record values or rotate them here. Standardize names and place private AI requests behind a backend proxy in a later security change.
- Firebase client configuration is public initialization metadata and must remain intact. The Firebase project ID is `smart-gebere-d230e`.
- Firestore rules permit the currently used user/farmer roots, but schema naming is inconsistent. A normalized GreenPlan schema needs a separate approved design and migration plan.

## Branding audit

User-visible Smart Gebere branding occurs in the splash screen and native iOS/web/Android display names. Documentation also uses the legacy name and Ethiopian framing. `smart_gebere` is additionally the Dart package name, native identifiers, and Firebase-linked Android package. Only user-visible strings and documentation are safe candidates for a later branding-only change. Do not rename package, application/bundle IDs, Kotlin path, Firebase app IDs, or Firebase project in Phase 1.

## Completed deletion list

Cleanup Batch 1 was approved and completed after a final dependency verification. The following files were deleted:

1. `lib/controller/account_controller.dart`
2. `lib/controller/auth_controller.dart`
3. `lib/controller/chat_controller.dart`
4. `lib/controller/navigation_controller.dart`
5. `lib/controller/onboarding_controller.dart`
6. `lib/controller/privacy_setting_controller.dart`
7. `lib/controller/theme_controller.dart`
8. `lib/models/chat_model.dart`
9. `lib/models/message_model.dart`
10. `lib/models/user_model.dart`
11. `lib/utils/helper_functions.dart`
12. `lib/utils/device/device_utility.dart`

Reason: unreachable legacy code; the controller/model group imports a removed `chewata` application and the utility group imports absent GetX. No file was skipped. The five protected root `photo_*.jpg` files were not modified. All other candidates remain REVIEW or REFACTOR LATER and require separate approval.

## Batch 1 dependency verification

Immediately before deletion, every approved path was searched across `lib/`, `test/`, platform directories, `.github/`, `pubspec.yaml`, `analysis_options.yaml`, and Firebase configuration. No active source import, route, dependency-injection registration, test, platform integration, or code-generation configuration referenced an approved file. The only internal references were among the deleted legacy chat/controller/model group. The active `lib/stream/stream_provider.dart` declares its own `UserModel`; it does not import or depend on the deleted `lib/models/user_model.dart`.

## Requirement conflicts and risks

- The proposal explicitly excludes open-field cultivation, while the active field-mapping feature targets fields. Keep it for review until the inaccessible UI/specification documents are examined.
- The proposal specifies on-device TFLite disease detection; the active diagnosis implementation uses cloud Gemini. Preserve it, but label the implementation gap rather than treating it as complete compliance.
- The proposal names Open-Meteo; current code uses varying weather APIs and keys. Do not choose one during cleanup.
- The proposal calls for PDF export and local notifications; packages and implementation are not present. These are future modules, not cleanup additions.
- Tests use the existing `smart_gebere` package name. Renaming it now would be a coordinated migration, not safe branding cleanup.
