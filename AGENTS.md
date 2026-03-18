# Repository Guidelines

## Project Structure & Module Organization
- `lib/`: application code
  - `common/`: global config, networking (`dio`), caching
  - `models/`: JSON models (generated files end in `*.g.dart`)
  - `routes/`: screens/pages (navigation targets)
  - `states/`: `provider`/`ChangeNotifier` state models
  - `widgets/`: reusable UI components
  - `l10n/`: generated localization output
- `test/`: Flutter unit/widget tests (e.g. `test/widget_test.dart`)
- `imgs/`, `fonts/`: bundled assets referenced from `pubspec.yaml`
- `l10n-arb/`: ARB localization sources
- `android/`, `ios/`: platform runners and build configuration

## Build, Test, and Development Commands
```sh
flutter pub get          # install dependencies
flutter run              # run on a simulator/device
flutter test             # run all tests
flutter analyze          # static analysis (uses flutter_lints)
dart format .            # auto-format Dart code
dart run build_runner build --delete-conflicting-outputs  # regenerate code
./intl.sh                # (legacy) regenerate localization from `l10n-arb/`
```
Tips:
- List devices: `flutter devices`
- Clean rebuild: `flutter clean`
- i18n note: `./intl.sh` is a legacy flow (may require dependency/migration work).

## Coding Style & Naming Conventions
- Formatting: use `dart format .` (2-space indentation; standard Dart style).
- Linting: keep `flutter analyze` clean; rules come from `analysis_options.yaml`.
- Naming: `lower_snake_case.dart` files, `UpperCamelCase` classes, `lowerCamelCase` members.
- Don’t hand-edit generated code (`lib/**.g.dart`, `lib/l10n/**`).

## Testing Guidelines
- Framework: `flutter_test`.
- Name tests `*_test.dart` and place them under `test/`.
- Prefer focused runs while iterating: `flutter test test/widget_test.dart`.

## Commit & Pull Request Guidelines
- Existing commits are short, descriptive, and imperative (English/中文 both appear).
- Keep commits scoped (one logical change each).
- PRs should include: what/why, how tested (commands + device), and screenshots for UI changes.

## Security & Configuration Tips
- Treat GitHub tokens as secrets: never commit them or log `Authorization` headers.
- Generated/build outputs should stay untracked (`/build/` is ignored by `.gitignore`).
