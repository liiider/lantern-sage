# Lantern Sage Mobile

Flutter client skeleton for the Lantern Sage iOS MVP.

## Current Scope

- Four-tab shell: Today, Ask, History, Profile
- Ritual Parchment theme translated from the HTML prototype
- API client path for guest registration, Today, Ask, History, feedback, settings,
  and Important Date guidance
- Static fallback data when the backend is unavailable during local development
- MVP access is unrestricted while functionality is being completed and tested
- Generated iOS platform directory is present for later macOS/Xcode validation

## Local Flutter Verification

Run from this directory:

```powershell
flutter pub get
flutter analyze
flutter test
```

Then wire `LanternSageApiClient` to the deployed or local backend base URL.

For a local backend, pass the API URL at run time:

```powershell
flutter run --dart-define=API_BASE_URL=http://127.0.0.1:8000
```

When testing on an iOS simulator, use the host address that can reach the FastAPI
service from that simulator or device.

## iOS Build Requirement

The Flutter source can be developed on Windows. Building, signing, simulator testing,
and TestFlight upload require macOS with Xcode, or a macOS CI service.
