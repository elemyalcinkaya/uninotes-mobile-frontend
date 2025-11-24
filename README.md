# UniNotes Mobile (Flutter)

Mobile Flutter version of the UniNotes web frontend you provided.

## Screens
- Home: navigation cards to main sections
- About: gradient header, features, and contact actions
- Shared Notes: class → semester → notes flow with dummy data
- Add Notes: file picker and upload simulation
- Profile: editable fields and image picker

## Requirements
- Flutter 3.22+ (Dart 3.4+)

## Setup
1. Add your logo image at `assets/images/last-logo.png` (same filename as the web).
2. Install dependencies:
```bash
flutter pub get
```
3. Run the app:
```bash
flutter run
```

## Notes
- File picking uses `file_picker`.
- Image picking uses `image_picker` (requires iOS/Android permissions; Flutter adds defaults, but check platform docs if needed).
- Data under Shared Notes is the same dummy content from the web app.
# uninotes_mobile

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
