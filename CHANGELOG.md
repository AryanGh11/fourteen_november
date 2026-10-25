# Changelog

## 1.2.0

Brings the app back to building on Flutter 3.47, and adds alerts, a backgrounds screen, server-backed stats and a profile screen.

### Before installing

Run `setup_general_stats.js` in the API project once. It creates the table behind the stats screen and fills it with the dates the app used to have built in. Until then, the hug and together-since stats show a dash.

### Added

- **In-app alerts.** A message shown for a set window of time, such as the monthly anniversary, in a dialog over the home screen. Alerts can have a title and can be closable or not. Closing one is remembered per person on the server, so it stays closed after a reinstall and closing it on one phone does not hide it from the other. Alerts are checked on launch with a short wait, so a slow connection does not hold up the splash screen.
- **Backgrounds screen.** Every background full screen, swiped through like a carousel, with pull to refresh. Backgrounds can be added from the gallery and deleted from here, and the home screen's backdrop picks up the change straight away.
- **Profile screen.** Tap your avatar on the home screen to change your name and photo. Both are saved to the server, so the other person sees the change.
- **Pull to refresh on the stats screen**, refreshing everything the stats are worked out from.

### Changed

- **The stats screen's dates now live on the server.** The last-hug and together-since dates were built into the app; they can now be updated after a visit without a new release. They were also read in each phone's own time zone, so the two counters ran 1.5 to 2.5 hours apart; both phones now count from the same moment.
- **Moved to Flutter 3.47.** Two packages no longer worked with it, so they were replaced with their maintained versions: Hive with `hive_ce`, which reads the data already stored on each phone, and the icon set with `lucide_icons_flutter`. The iOS project was updated by Flutter itself, which raises the minimum to iOS 15. The Android build moves to the versions Flutter 3.47 requires: Gradle 8.14.3, Android Gradle Plugin 8.11.1 and Kotlin 2.2.20.

### Fixed

- The stats screen no longer crashes when the users have not loaded yet; missing values show a dash instead.

### Known issues

- A failed initial sync is logged rather than reported, so the app can open with no data on a bad first connection.
- Most data can be read and changed by anyone holding the project id, which ships in the app. The stats dates are the exception: they are read only.

## 1.1.0

Location becomes dynamic. The app reads the device's coordinates and derives everything else from them, rather than relying on a city typed into the database, so both the distance and the weather stay right when either of us travels.

### Added

- Device location via `geolocator`, requested on demand only — no background tracking. Refusals are reported specifically enough to tell someone whether to switch on GPS or re-enable the permission in Settings.
- `Weather.region` alongside the locality name, since a precise fix resolves to the nearest place, which can be a neighbourhood rather than the city.

### Changed

- Weather is looked up by coordinates instead of a stored city name. The API returns the resolved place, so nothing has to be stored or kept in sync.
- `cityName` is gone from the user record.
- The weather screen shows one card per person rather than one per city; the previous grouping dropped a person whenever both were in the same place.
- The weather API is called over https. Android blocks cleartext traffic by default, so the previous http endpoint worked on iOS and failed on Android.

### Known issues

Unchanged from 1.0.0: a failed initial sync is logged rather than surfaced, the stats screen assumes two users are cached, and data is readable and writable by anyone holding the project id.

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
