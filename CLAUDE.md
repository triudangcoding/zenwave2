# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Commands

- Install dependencies: `flutter pub get`
- Run the app on a connected simulator/device: `flutter run`
- Static analysis: `flutter analyze`
- Run all tests: `flutter test`
- Run a single test file: `flutter test test/widget_test.dart`
- Run tests matching a name: `flutter test --plain-name "test name"`
- Build iOS app: `flutter build ios`
- Build Android APK: `flutter build apk`
- Build macOS app: `flutter build macos`

## Repo-specific guidance

- This is a Flutter app using Material widgets and a small in-memory state layer; there is no backend, persistence layer, or API client in the current codebase.
- `analysis_options.yaml` only includes `package:flutter_lints/flutter.yaml`; use `flutter analyze` as the main lint/static-check command.
- The current `test/widget_test.dart` is still the default Flutter counter smoke test and does not match the app’s actual UI flow.
- Recent local changes include CocoaPods-related iOS/macOS files (`ios/Podfile`, `macos/Podfile`, generated Flutter xcconfig files, `pubspec.lock`), so be careful not to overwrite platform setup changes when editing unrelated code.

## Architecture overview

### App shell and navigation

- `lib/main.dart` is the app entry point. `MyApp` creates a single `MaterialApp` and routes directly to `_AppRoot`.
- `_AppRoot` switches between onboarding and the main app shell by listening to `AppStateService.isOnboardedNotifier`.
- After onboarding, the app renders `MainTabPage`, a four-tab shell with Home, Meditation, Health Management, and Profile sections.
- Cross-tab navigation is coordinated through `lib/core/navigation/tab_navigation_controller.dart`, which exposes a global `ValueNotifier<int>` rather than using a routing package.

### State model

- Global state lives in `lib/services/app_state_service.dart`.
- State is intentionally lightweight and entirely in memory, built from static fields and `ValueNotifier`s.
- This service currently owns:
  - onboarding completion and saved onboarding answers
  - device connection status
  - stress/relaxation EEG-like scores
  - recommendation logic used by the home screen
- Because state is not persisted, app restarts reset onboarding, device, and score state.

### Design system and UI composition

- Shared color tokens are centralized in `lib/core/theme/app_colors.dart`.
- Most screens are large, self-contained widget files with private helper widgets/methods instead of feature-level controllers, repositories, or separate state classes.
- The codebase is organized primarily by product surfaces under `lib/sections/` and `lib/screens/`:
  - `sections/` contains the main tab destinations and deeper product surfaces such as home, meditation, health management, brain overview, and meditation space.
  - `screens/` contains cross-cutting or flow-style experiences such as onboarding, breathing exercises, and assessment mocks.

### Feature flows

- Onboarding (`lib/screens/onboarding/WelcomeOnboardingScreen.dart`) is a fixed five-page flow: intro, three questionnaire pages, and a completion screen. Finishing onboarding calls `AppStateService.completeOnboarding(...)`, which flips the root app state.
- Home (`lib/sections/home/HomePage.dart`) is the most state-aware screen. It reacts to `AppStateService` notifiers with nested `ValueListenableBuilder`s to update recommendation content and EEG/device sections.
- The home screen also contains a side-sheet style mock device connection flow implemented inline as private widgets/state classes. That flow currently simulates scanning and connecting locally rather than delegating to a device service.
- Health Management currently resolves to `ConnectDevicePage` (`lib/sections/health_management/HealthManagementPage.dart`), so that tab is effectively a single-feature entry into the device/relaxation flow.
- Brain overview (`lib/sections/brain_overview/BrainOverviewPage.dart`) renders custom charts via `CustomPainter` and animates between day/week/month mock datasets.
- Meditation and profile features are currently UI-first and mostly static, with navigation driven directly from widget callbacks.

## Guidance from repo instructions

- Follow the agent doctrine in `AGENTS.md`: explore first, make bounded plans, prefer narrow edits, verify before claiming completion, and do not widen scope without approval.
- There is a Copilot instruction file at `.github/copilot-instructions.md`, but its content is generic operating guidance rather than repo-specific architecture.
- `README.md` is the default Flutter starter README and does not contain additional project-specific workflow details.
