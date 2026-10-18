# GreenPlan Future Modules

## Target modules

| Module | Responsibility | Existing starting point | Missing or migration work |
| --- | --- | --- | --- |
| App shell and auth | Startup, session state, login, registration, profile, route guards | `main.dart`, splash/onboarding/login/signup, `features/auth/**` | Select one auth path and connect DI/view models. |
| Greenhouse profile | Rectangular greenhouse dimensions, aisle, tiers, location | Farm profile/entities | Replace open-field terminology and agree Firestore schema. |
| Crop planning and calculations | Spacing, packet count, seeds, fertilizer, water | Farmer/crop/week entities and task/crop screens | Add unit-tested greenhouse calculation engine and visual layout. |
| Weather and crop recommendation | Forecast, seasonal scoring, companion warnings | Weather service/advisor/location code | Select Open-Meteo-compatible provider and single cache/API boundary. |
| Disease detection | Capture/pick image, classify, treatment, history | Disease page, detection history, image picker | Decide cloud versus required TFLite/on-device classifier. |
| AI advisor | Contextual crop-care chat | AI doctor and reliability service | Server-side proxy, structured prompts, history and error policy. |
| Growth calendar | Planting/watering/fertilizer/harvest tasks and reminders | Scheduling/task/crop lifecycle files | Add local notifications, greenhouse-specific rules and photo journal. |
| Harvest and finance | Yield estimate, costs, revenue, break-even and charts | Yield prediction, records, market prices, `fl_chart` | Implement cost model and plan-level financial entities. |
| Offline and sync | Local plans, cache, retry queue and reconciliation | Hive offline storage and connectivity service | Define conflict policy and normalized GreenPlan repositories. |
| Export and settings | PDF plan export, language/theme/units/preferences | Settings/localization | Add `pdf`/`printing` only when export is implemented. |

## Suggested boundaries for six developers

Work should be divided by module boundary rather than assigning people now: (1) app shell/auth/cloud schema, (2) greenhouse and calculation domain, (3) crop recommendation/weather, (4) disease detection, (5) AI advisor and reliability, and (6) growth calendar/finance/export/testing. Each module should expose domain interfaces and avoid direct cross-feature widget imports.

## Recommended migration order

1. Approve and remove confirmed legacy code, then run the baseline checks.
2. Document the GreenPlan Firestore schema without migrating legacy data.
3. Choose the active Auth and Farmer repository paths and wire dependency injection.
4. Build the calculation engine with unit tests before replacing dashboard screens.
5. Consolidate weather and AI provider access behind services/repositories.
6. Implement the greenhouse-focused UI and future modules incrementally.

## Architecture direction

Use `app/` for application shell/router/theme, `core/` for shared services/errors/network/utils/widgets, and feature folders with presentation, domain, and data layers. Do not create empty folders prematurely. Move a module only when its tests and imports can migrate together.
