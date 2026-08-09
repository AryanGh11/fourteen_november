# Changelog

## 1.0.0

First tagged release.

### Backend

Migrated from a self-hosted PocketBase instance to Appwrite Cloud. The app previously reached its backend through an ngrok tunnel, which meant it only worked while a laptop was on and the tunnel was up, with a URL that changed on every restart. The endpoint is now permanent, so the app works whenever either person opens it.

All existing records and images were migrated, reusing the PocketBase record ids so relations between users, posts, comments and moods carried over unchanged.

### Added

- **Stats screen** — time since the last visit, distance between the two users, relationship duration, and memory/mood counts, updating every second
- **Weather screen**
- `cityName`, `locationLat` and `locationLng` on the user model, backing the distance calculation
- `custom-circle-avatar` and `shimmer-placeholder` shared widgets

### Fixed

- Records beyond the first 25 in a table were never fetched, so newly created moods and posts appeared to vanish on refresh
- `AnimatedBackground` crashed when the background list was empty, and read out of range when it held exactly one image
- Timestamps are converted to local time at the model boundary, so every screen shows a consistent time

### Changed

- iOS bundle identifier moved off the `com.example.*` placeholder
- Android `compileSdk` raised to 36, Android Gradle plugin to 8.10.0
- Removed the manual "paste new API endpoint" workaround, which the permanent endpoint makes unnecessary

### Known issues

- A failed initial sync is logged but not surfaced: the app opens on an empty database rather than reporting that it could not reach the backend
- The stats screen assumes two users are cached and throws if the sync above has failed
- Data is readable and writable by anyone holding the project id, which ships in the app bundle
