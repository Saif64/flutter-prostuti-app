# prostuti

A Flutter student-learning app — courses, lessons, mock tests, flashcards, leaderboard, chat and payments.
Bangla is the default UI language, English the alternate. Android and iOS only.

## Setup

Flutter is pinned via [FVM](https://fvm.app) in `.fvmrc`. Install FVM, then from the repo root:

```
fvm install          # installs the pinned SDK into .fvm/
fvm use              # links this project to it
fvm flutter pub get
```

Point your editor at `.fvm/flutter_sdk` so the analyzer matches the build SDK.

## Code generation

Riverpod providers (`*.g.dart`) and the localization output are committed, but must be regenerated
alongside any source change:

```
fvm dart run build_runner watch --delete-conflicting-outputs   # while developing
fvm dart run build_runner build --delete-conflicting-outputs   # one-shot
fvm flutter gen-l10n                                           # after editing lib/l10n/*.arb
```

## Run

A **flavor and entrypoint are always required**. A bare `flutter run` makes Gradle build every flavor at
once, and the parallel Flutter build steps collide while regenerating `lib/l10n/app_localizations*.dart`,
which fails the build.

```
fvm flutter run --flavor development -t lib/main_development.dart
fvm flutter run --flavor staging     -t lib/main_staging.dart
fvm flutter run --flavor production  -t lib/main_production.dart
```

## Android builds

Release variants are signed with the `release` signingConfig, which reads `android/key.properties`.
That file and the keystore it points at are not in the repo — obtain them from the team, or release builds
fail with `SigningConfig "release" is missing required property "storeFile"`. Debug builds need no keystore.

`android/key.properties`:

```
storePassword=<...>
keyPassword=<...>
keyAlias=<...>
storeFile=<path to .jks, relative to android/>
```

```
fvm flutter build apk --flavor development --release -t lib/main_development.dart
fvm flutter build apk --flavor staging     --release -t lib/main_staging.dart
fvm flutter build apk --flavor production  --release -t lib/main_production.dart
```

## iOS builds

Archiving from Xcode is preferred, and upload the symbol files as well.

```
fvm flutter build ipa --flavor production -t lib/main_production.dart
```

Upload Crashlytics symbols:

```
Pods/FirebaseCrashlytics/upload-symbols -gsp Runner/GoogleService-Info.plist -p ios build/Runner.xcarchive/dSYMs
```

## Scaffolding a feature

New features are generated from the `pros` Mason brick, which lays out the standard
`model/ repository/ viewmodel/ view/ widgets/` structure. Install the CLI once — it does not ship with Flutter —
and make sure the pub cache `bin` directory is on your `PATH`:

```
dart pub global activate mason_cli
```

Then, **from the repo root**:

```
mason get
mason make pros --name <feature_name>
```

Mason resolves the brick relative to the working directory, so these commands do not work from a subdirectory.
`mason-lock.json` is regenerated per machine and is not tracked.
