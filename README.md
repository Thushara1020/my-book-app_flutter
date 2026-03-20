# Connect – Flutter Social App

A mobile social networking app built with Flutter and SQLite that lets users create posts, react with likes, and manage their personal profile.

## Features

- **Post Feed** – Create and browse posts with text and/or photos from your gallery.
- **Like System** – Tap the like button on any post to increase its like count, persisted to the local database.
- **Profile Page** – View your name, bio, and stats (posts, followers, following). Edit your name and bio through a dialog, and update your profile picture from the gallery.
- **Local Persistence** – All data (posts and profile) is stored locally using SQLite via the `sqflite` package — no internet connection required.
- **Material 3 UI** – Clean, modern interface with a blue accent color scheme, glassmorphism profile card, and responsive layout.

## Screenshots

| Home / Feed | Profile |
|---|---|
| Post feed with like & share actions | Glassmorphism profile card with stats |

## Tech Stack

| Layer | Technology |
|---|---|
| Framework | Flutter (Dart) |
| Local Database | SQLite (`sqflite ^2.3.0`) |
| Image Picker | `image_picker ^1.0.7` |
| Path Utilities | `path ^1.9.0` |
| Icons | `cupertino_icons ^1.0.8` |

## Getting Started

### Prerequisites

- [Flutter SDK](https://docs.flutter.dev/get-started/install) 3.11.1 or higher
- Android Studio / Xcode (for running on an emulator or physical device)

### Installation

```bash
# Clone the repository
git clone https://github.com/Thushara1020/my-book-app_flutter.git
cd my-book-app_flutter

# Install dependencies
flutter pub get

# Run the app
flutter run
```

## Project Structure

```
lib/
├── main.dart            # App entry point, Home screen, post feed
├── database_helper.dart # SQLite database setup and CRUD helpers
└── profile_page.dart    # Profile view and edit dialog
```

## Database Schema

**users** table – stores the single user profile

| Column | Type | Description |
|---|---|---|
| id | INTEGER PK | Auto-increment |
| name | TEXT | Display name |
| bio | TEXT | Short bio |
| profileImage | TEXT | Path to profile image file |

**posts** table – stores user posts

| Column | Type | Description |
|---|---|---|
| id | INTEGER PK | Auto-increment |
| userName | TEXT | Author's display name |
| postContent | TEXT | Text body of the post |
| imagePath | TEXT | Optional path to an attached image |
| createdAt | TEXT | Timestamp label |
| likes | INTEGER | Like counter (default 0) |

## Contributing

Pull requests are welcome. For major changes, please open an issue first to discuss what you would like to change.

## License

This project is open source and available under the [MIT License](LICENSE).

