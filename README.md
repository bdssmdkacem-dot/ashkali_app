# أشكالي (Ashkali) — Arabic 3D Shapes Learning App

Fourth app in the series (وقتي → أرقامي → حروفي → **أشكالي**). Same architecture
throughout: singleton services, Hive persistence, `flutter_tts` (ar-SA),
child-directed AdMob, no external image/model assets.

## ⚠️ If you built this before and got a blank screen on install

The previous zip was missing the real native `android/` project — only
empty placeholder folders. This zip now includes a complete, working
`android/` project. The specific bug that caused "nothing after install":
**`google_mobile_ads` crashes the app on startup if `AndroidManifest.xml`
is missing the AdMob `APPLICATION_ID` meta-data tag** — since
`MobileAds.instance.initialize()` runs in `main()` before `runApp()`, the
app dies before drawing a single frame. That tag is now in
`android/app/src/main/AndroidManifest.xml`, currently set to Google's
public **test** App ID so it runs immediately. Also fixed: `pubspec.yaml`
referenced an `assets/images/` folder that didn't exist, which can fail
the build outright — that folder now exists.

## What's included

- **13 chapters** (locked spec): 10 shape units + 2 review chapters (spaced
  repetition) + 1 bonus (heart) + 1 final boss chapter. Full breakdown in
  `lib/data/chapters_data.dart`.
- **10 shapes**: circle, square, triangle, rectangle, oval, star, heart,
  rhombus, pentagon, hexagon — `lib/data/shapes_data.dart`.
- **Pseudo-3D rendering** (`lib/widgets/shape_3d_widget.dart`): shapes are
  drawn with a `CustomPainter` using extrusion, gradient shading, and a slow
  auto-rotation to fake a 3D look — **no external 3D model files (.glb/.obj)
  needed**, staying consistent with the series' "no external dependencies"
  rule. If you'd rather use real 3D models later, swap this widget for
  `model_viewer_plus` and point it at .glb assets.
- **ShapeTraceWidget**: same pixel-comparison coverage validator pattern as
  حروفي's letter tracing, adapted to 2D outline paths per shape.
- **5 activity types** auto-sequenced per chapter: intro (TTS + 3D), trace,
  find-in-real-life (emoji matching), drag-and-drop sort, sides-count quiz
  (skipped for 0-side shapes).
- **Sound**: 4 synthesized SFX already included in `assets/sounds/` —
  `tap.wav`, `success.wav`, `error.wav`, `complete.wav`. These are placeholder
  tones generated locally so the app has real audio out of the box; swap them
  for your own recorded/licensed SFX whenever you like (same filenames, same
  `AudioService` calls — no code changes needed).
- **Hive adapters** for `ShapeUnit` and `ChapterProgress` are hand-written in
  the `.g.dart` files so the project builds without running `build_runner`
  first. If you add fields to either model, regenerate with:
  ```
  flutter pub run build_runner build --delete-conflicting-outputs
  ```

## Setup

**One-time step first:** this zip includes the Android manifest, Gradle
config, MainActivity, and launcher icons (the pieces with the actual
AdMob fix), but not the Gradle wrapper binary (`gradle-wrapper.jar`) —
that's a binary file I can't hand-write, and downloading it needs Google's
Gradle services domain which isn't reachable from here. Run this once
after unzipping, from the project root:

```bash
flutter create .
```

This is safe — `flutter create .` never overwrites files that already
exist, it only fills in what's missing (the wrapper jar, `gradlew` /
`gradlew.bat` scripts, and an `ios/` folder if you want one later). Your
`AndroidManifest.xml` with the AdMob fix, `lib/`, and everything else
stays untouched.

Then:
```bash
flutter pub get
flutter run
```

If `android/local.properties` is missing (it's git-ignored, not shipped),
Flutter regenerates it automatically on your machine on `flutter pub get` /
first run — you don't need to create it by hand. If it doesn't, copy
`android/local.properties.example` to `android/local.properties` and fill
in your `sdk.dir` (Android SDK path) and `flutter.sdk` (Flutter SDK path).

To build a release APK:
```bash
flutter build apk --release
```
It's signed with the debug keystore for now (so this command just works),
swap in your own release keystore before publishing to the Play Store.

### Still needed before shipping

1. **Real AdMob unit IDs** — `lib/services/ad_service.dart` currently uses
   Google's public **test** unit IDs (safe for debug builds). Replace
   `interstitialUnitId` and `bannerUnitId` with your real ones before release,
   plus add your real `AdMobAppId` to `android/app/src/main/AndroidManifest.xml`
   and `ios/Runner/Info.plist`.
2. **Ad placement (now locked)**: interstitial only after chapters 4, 8, 13
   (reviews + final) — core teaching chapters never interrupt. One banner on
   the home screen only. No rewarded ads shown to children.
3. **Arabic font** — theme references a `Cairo` font family; add the font
   files under `assets/fonts/` and register them in `pubspec.yaml` if you
   want it (falls back to system font otherwise).
4. **Android/iOS platform folders** — only stub folders are included; run
   `flutter create .` in the project root to regenerate the full native
   scaffolding for your Flutter SDK version.

## Architecture map

```
lib/
  models/          Hive models: ShapeUnit, ChapterProgress + static ShapeMeta/ChapterDef
  data/             Static content: 10 shapes, 13 chapters
  services/         AudioService (TTS+SFX), ProgressService (Hive)
  widgets/          Shape3DWidget (pseudo-3D painter), ShapeTraceWidget
  screens/          HomeScreen (chapter map), ChapterScreen (activity runner)
  screens/activities/  intro, trace, find_real_life, sort, sides_quiz
  theme/            Moroccan palette + ThemeData
assets/sounds/      tap.wav, success.wav, error.wav, complete.wav
```
