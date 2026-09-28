# News App

Flutter app that shows news from public RSS feeds. Categories come from BBC, search uses Google News. No API key.

## Run

```bash
flutter pub get
flutter run
```

## Layout

- `lib/rep/` repository + RSS data source
- `lib/bloc/news/` loads categories, search, refresh
- `lib/screens/` home and article details

## Tests

```bash
flutter test
```

Parser tests use a sample RSS string, they don't hit the network.

## Zip / hand-in

Don't send `build/`, `.dart_tool/`, or `__MACOSX/`. Run `flutter clean` first if you're zipping the project.
