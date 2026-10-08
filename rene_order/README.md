# FLOWERBONIA

A responsive Flutter flower-shop mini app for Android and iOS.

## Included
- Home, About, Products, Reviews, Contact
- Light / dark mode
- Functional favorites with local persistence
- Functional cart with quantity controls and local persistence
- User-provided product and background assets
- User-provided About video
- SVG contact icons
- Filipino review text
- App launcher icon configured from the provided shop icon

## Build requirements
- Flutter stable (Dart 3.4+)
- Android Studio / Android SDK for APK
- Xcode on macOS for iOS

## Run
```bash
flutter pub get
flutter pub run flutter_launcher_icons
flutter run
```

## Build APK
```bash
flutter build apk --release
```
Output: `build/app/outputs/flutter-apk/app-release.apk`

## Build App Bundle
```bash
flutter build appbundle --release
```

## Build iOS
```bash
flutter build ios --release
```

Before publishing, replace the demo contact details and connect the contact/checkout buttons to your real backend or ordering channel.
