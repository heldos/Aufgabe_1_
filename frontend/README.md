# Flutter frontend

This repo does not commit the full platform scaffolding (`android/`, `ios/`, …).

## Create the Flutter project scaffolding

From `frontend/`:

```powershell
flutter create .
```

Then replace the generated `lib/main.dart` with the version in this repo (we provide one), and add dependencies from `pubspec.yaml` (next steps).

## Running

```powershell
flutter pub get
flutter run
```

## Backend address notes

- Android emulator typically reaches host services via `10.0.2.2`
- iOS simulator typically can use `localhost`
- If running against GKE, you’ll use the backend Service external IP (or a DNS name) on port `50051`

