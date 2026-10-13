# Infinite Gallery

[GitHub repository](https://github.com/joesaniya/Gallery_App)

Infinite Gallery is a Flutter app for browsing Pixabay images, saving favorites,
and downloading images to the device.

## Requirements

- Flutter SDK with Dart 3.9.2 or later
- Android Studio and Android SDK to build or run on Android

Check that Flutter can find the required tools:

```sh
flutter doctor
```

## Setup

From the project directory, fetch dependencies:

```sh
flutter pub get
```

## Pixabay API key(58020013-4f153a88a32c084c9804ad320)

Create or retrieve a Pixabay API key from the [Pixabay API documentation](https://pixabay.com/api/docs/).
The app reads the key from the `PIXABAY_API_KEY` Dart compile-time environment
variable. Pass your key when running or building the app:

```sh
flutter run --dart-define=PIXABAY_API_KEY=your_pixabay_api_key
```

Replace `your_pixabay_api_key` with your key. Use the same option for other
commands that need to make Pixabay requests, such as `flutter build apk`.
The current app configuration also contains a fallback key; a value supplied
with `--dart-define` takes precedence.

**Key handling:** A Dart compile-time define is embedded in the built client app
and can be recovered from it. Do not treat it as secure secret storage or commit
your own key to source control. Apply any API restrictions and usage limits
Pixabay provides for your key.

## Architecture and state management

The code is organized by responsibility under `lib/`:

- `core/` contains app configuration, typed errors, and shared theme definitions.
- `data/models/` defines image and paged-result data structures.
- `data/services/` handles Pixabay HTTP requests, favorites persistence, and image downloads.
- `data/repositories/` provides the `ImageRepository` abstraction and its Pixabay-backed implementation.
- `presentation/` contains screens, reusable widgets, and the app's state providers.
- `app.dart` wires dependencies and providers together; `main.dart` initializes `SharedPreferences` before starting the app.

The app uses `provider` with `ChangeNotifier` for mutable UI state. `InfiniteGalleryApp` registers the image repository and download service as providers, and registers `GalleryProvider`, `FavoritesProvider`, and `ThemeProvider` as change notifiers. Screens read or watch the provider they need; calling `notifyListeners()` rebuilds listening widgets.

State ownership is separated by feature:

- `GalleryProvider` owns image results, the current search and category, paging, loading flags, and errors. It requests data through `ImageRepository`, filters duplicate image IDs, and ignores responses from outdated searches or refreshes.
- `FavoritesProvider` loads saved images when created and updates the in-memory favorites map when a favorite is toggled. It persists changes through `FavoritesStorage`; if persistence fails, it rolls back the in-memory change.
- `ThemeProvider` loads the saved theme mode at startup and persists mode changes to `SharedPreferences`. The app widget listens to it to select the light, dark, or system theme.

For gallery requests, the flow is `screen -> GalleryProvider -> ImageRepository -> PixabayApiService -> Pixabay API`. The service converts response JSON into models and maps network/API failures to typed app exceptions, which the provider exposes to the UI. Favorites use a separate local flow: `FavoritesProvider -> FavoritesStorage -> SharedPreferences`.

## Run and test

```sh
flutter run --dart-define=PIXABAY_API_KEY=your_pixabay_api_key
flutter analyze
flutter test
```

## Build Android APK

```sh
flutter build apk --release --dart-define=PIXABAY_API_KEY=your_pixabay_api_key
```

The APK is written to `build/app/outputs/flutter-apk/app-release.apk`. The
Android release build currently uses the debug signing configuration, so it is
for local testing only. Configure a production keystore before distributing a
release build.
