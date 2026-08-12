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

- **15 chapters**: 10 shape units + 2 review chapters (spaced repetition) +
  1 bonus (heart) + 1 shape-mastery final challenge + **2 new formula
  chapters** (المحيط / perimeter, المساحة / area). Full breakdown in
  `lib/data/chapters_data.dart`.
- **Formula chapters (14-15)**: each shape step opens with a `ruleIntro`
  screen - the formula plus a simplified Arabic explanation, read aloud via
  TTS - before the `calc` quiz (random small integers, multiple-choice
  answer). Chapter 14 covers circle/square/triangle/rectangle/rhombus/
  pentagon/hexagon (oval/star/heart skipped - no simple formula at this
  level); chapter 15 covers square/rectangle/triangle only. See
  `lib/data/formulas_data.dart` for the rule text and calculations.
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
  find-in-real-life (illustrated image matching), drag-and-drop sort,
  sides-count quiz (skipped for 0-side shapes). Chapter 13 (final challenge)
  composes sort + find-in-real-life + sides-quiz across all 10 shapes as a
  genuine mixed recall test, not a placeholder.
- **Sound**: 6 synthesized SFX in `assets/sounds/` — `tap.wav`, `success.wav`,
  `error.wav`, `complete.wav`, `unlock.wav` (new chapter unlocks),
  `star.wav` (star-earned twinkle). All placeholder tones generated
  locally so the app has real audio out of the box; swap them for your own
  recorded/licensed SFX whenever you like (same filenames, same
  `AudioService` calls — no code changes needed).
- **Images**: `assets/images/objects/` has 35 illustrated real-world
  objects for the "find it in real life" activity (replacing the earlier
  emoji placeholders). `assets/images/shape_icons/` has 10 flat shape
  thumbnails used as the leading icon on each core/bonus chapter's home
  screen tile.
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
   plus swap the test `APPLICATION_ID` in
   `android/app/src/main/AndroidManifest.xml` for your real AdMob App ID.
2. **Ad placement (locked)**: interstitial only after chapters 4, 8, 13
   (reviews + final) — core teaching chapters never interrupt. One banner on
   the home screen only. No rewarded ads shown to children.
3. **Arabic font** — theme references a `Cairo` font family but no font
   file is bundled, so it silently falls back to the system font (not a
   crash, just not the intended look). Add the font files under
   `assets/fonts/` and register them under `flutter: fonts:` in
   `pubspec.yaml` if you want the real typeface.
4. **iOS project** — `android/` is a complete, real native project now.
   `ios/` is not included (Xcode's project file format isn't safe to
   hand-write without Xcode to verify it). Run `flutter create .` once to
   generate it — safe, only adds what's missing, won't touch `android/` or
   `lib/`.
5. **Release signing** — release APK is currently signed with the debug
   keystore so `flutter build apk --release` works immediately. Generate
   your own keystore before publishing to the Play Store.

## Architecture map

```
lib/
  models/          Hive models: ShapeUnit, ChapterProgress + static ShapeMeta/ChapterDef
  data/             Static content: 10 shapes, 15 chapters, perimeter/area formulas
  services/         AudioService (TTS+SFX), ProgressService (Hive), AdService
  widgets/          Shape3DWidget (pseudo-3D painter), ShapeTraceWidget
  screens/          HomeScreen (chapter map), ChapterScreen (activity runner)
  screens/activities/  intro, trace, find_real_life, sort, sides_quiz
  theme/            Moroccan palette + ThemeData
assets/sounds/                 tap, success, error, complete, unlock, star (.wav)
assets/images/objects/         35 illustrated real-world objects
assets/images/shape_icons/     10 flat shape thumbnails (home screen tiles)
android/                        real native project (manifest, gradle, icons)
```

## Visual / UX polish

- **Home screen**: header with an animated overall-progress bar (X of 15
  complete), chapters grouped into "رحلة الأشكال" (shape journey) and
  "الرياضيات" (math) sections, each tile with a color accent strip matching
  its shape, star ratings, and a locked/unlocked fade state.
- **Chapter screen**: step progress bar + "الخطوة X من Y" counter, each
  activity fades/slides in as the child advances instead of hard-cutting,
  and chapter completion shows a dialog with stars popping in one at a
  time (bounce animation) instead of appearing all at once.
- **Consistent feedback everywhere**: `find_real_life`, `sides_quiz`, `calc`,
  and `sort` all share the same answer-tile look (`answerTileDecoration` in
  `theme/app_theme.dart`) - green/red tint, a check or cross badge, and a
  small scale animation on tap - instead of each screen rolling its own
  colors.
- **Theme-level consistency**: buttons, cards, and chips all pull from one
  `ThemeData` (`buildAppTheme()`) instead of being styled ad hoc per screen.

## Testing

`test/data/` has real unit tests (no plugins needed, run with plain
`flutter test`):
- `shapes_data_test.dart` - every shape has valid assets and correct side counts
- `chapters_data_test.dart` - all 15 chapters reference real shapes, formula
  chapters are wired to a real formula, chapter numbering is sequential
- `formulas_data_test.dart` - **the highest-value test in the suite**:
  verifies every perimeter/area formula computes the mathematically correct
  answer (e.g. a 3×5 rectangle's area is genuinely 15, not just "whatever
  the code returns"). A bug here would silently teach a child wrong math.

```bash
flutter test
```

## Robustness fixes (this pass)

- **Progress migration bug**: `ProgressService` used to only seed chapter
  progress `if (_box.isEmpty)`. Anyone who'd already played chapters 1-13
  in an earlier version (before 14/15 existed) would have a non-empty box,
  so chapters 14/15 would never get created - `progressFor(14)` would
  throw the moment they reached it. Now seeds any *missing* chapter
  individually, and unlocks a newly-added chapter if its predecessor was
  already completed.
- **TTS startup crash**: `AudioService.init()` ran `_tts.setLanguage(...)`
  unguarded in `main()`, before `runApp()` - the same failure shape as the
  earlier AdMob crash. A device/emulator with no TTS engine installed
  would crash on launch. Now wrapped in try/catch; if TTS genuinely isn't
  available, shape names just aren't spoken instead of the app not
  starting at all.

## Status

Everything in `lib/` and `assets/` is real, wired, and functionally complete
for the 15-chapter flow end to end. The 5 items above are the only pieces
that need something from you specifically (your AdMob account, your Apple
dev setup, your keystore) rather than more code.
