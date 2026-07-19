# Fonto Studio

A standalone, offline-first Persian/Arabic **text-on-image story editor** for Android, built with Flutter. Independent design inspired by the Fonto workflow — no proprietary logos or assets are copied.

> Status: **MVP**. Story editor, Gallery and Settings are functional. CI builds an installable release APK.

## Features

### Story editor
- Multiple text layers, Persian & English, **RTL / LTR** per layer
- Font picker with search, categories, favorites, recent and **live preview**
- Color, font weight, size, **letter spacing**, line height, alignment
- **Shadow**, **Stroke**, **Gradient fill**, rounded **background box**
- Move / rotate / scale by touch (pinch), plus precise sliders
- Opacity, bring-to-front
- **Undo / Redo** (full-history snapshots)
- Backgrounds: transparent, solid, or gradient; four canvas sizes
- **Save drafts** and reopen them
- **Export transparent PNG** at full document resolution (share sheet)

### Gallery
- Ready-made **backgrounds** and full **templates** that apply to the editor
- Search across items — every item is functional, nothing is a mockup

### Settings
- Language **فارسی / English**, light / dark / system theme
- Workspace accent color
- **Font management**: import your own **TTF/OTF** fonts at runtime

## Fonts & licensing

Bundled families are all **SIL Open Font License (OFL 1.1)**:
Vazirmatn, Shabnam, Sahel, Samim, Lalezar, Noto Sans Arabic, Noto Naskh Arabic.

Commercial families (IRANSans, the B-family, Dana, Morabba, …) are **not** bundled.
Add them yourself via **Settings → Import TTF/OTF font**; nothing unlicensed ships in this repo.

## Architecture

Modular, offline-first:

```
lib/
  core/            settings, theme, strings (fa/en), font catalog
  features/
    story/         models, editor state (undo/redo, export), canvas, inspector
    gallery/       gallery + font-picker + preset data
    settings/      settings screen
  shared/          reusable controls
```

State via `provider` + `ChangeNotifier`. Persistence via `shared_preferences`.

## Building

The `android/` folder is generated in CI (and locally) rather than committed, so
the build always matches the installed Flutter version:

```bash
flutter create --platforms=android --org com.fontostudio --project-name fonto_studio .
flutter pub get
flutter test
flutter build apk --release
```

CI (`.github/workflows/android-build.yml`) runs analyze + test + release build on
`ubuntu-latest` and publishes the APK as the **fonto-studio-release-apk** artifact.
