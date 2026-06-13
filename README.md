# Recipe App

A Flutter mobile application for browsing, creating, and managing personal recipes, built as part of the Fourtitude Application Developer (iOS/Android) technical assessment.

## Features

### Core
- **Recipe list** with category filter dropdown (driven by recipe types)
- **Add recipe** with name, category, photo, dynamic ingredient list, and dynamic step-by-step instructions
- **Recipe detail view** with edit and delete actions
- **Local persistence** using Hive — data survives app restarts
- **Pre-populated sample recipes** covering all recipe categories (Breakfast, Lunch, Dinner, Dessert, Snack, Beverage)
- Responsive layout that adapts to different screen sizes and orientations
- Material 3 design with a custom warm theme

### Bonus Features Implemented
- **Architecture Pattern** — Provider-based MVVM-style architecture separating UI (screens), state/view-model logic (`RecipeProvider`, `AuthService`), and data access (`RecipeRepository`)
- **Reactive Programming** — `StreamBuilder` (live updates to the recipe list via Hive's `.watch()`) and `FutureBuilder` (async recipe category loading)
- **Networking** — Recipe categories are fetched from a self-hosted JSON file on GitHub, with automatic fallback to a bundled local asset if the network is unavailable
- **Dependency Injection** — `get_it` service locator provides `RecipeRepository`, `RecipeTypeService`, and `AuthService` as injectable singletons, enabling testability and modularity
- **Authentication** — Register/login/logout flow with SHA-256 password hashing and session persistence (stays logged in until explicit logout)
- **Unit & Widget Tests** — Covers `RecipeRepository` CRUD operations, `AuthService` (registration, login, hashing, session handling), and a widget test for the login flow

## Tech Stack
- **Flutter** (Dart)
- **Hive** — local NoSQL storage
- **Provider** — state management
- **get_it** — dependency injection
- **http** — networking
- **crypto** — password hashing (SHA-256)
- **image_picker** — photo selection from gallery

## Getting Started

### Prerequisites
- Flutter SDK (stable channel)
- Android Studio / Xcode (for emulator or device)

### Setup
```bash
git clone https://github.com/niksyakir/recipe_app.git
cd recipe_app
flutter pub get
flutter pub run build_runner build --delete-conflicting-outputs
flutter run
```

### Running Tests
```bash
flutter test
```

### Building a Release APK
```bash
flutter build apk --release
```

## Usage
1. On first launch, create an account (username + password).
2. Browse pre-populated recipes, or use the category filter to narrow the list.
3. Tap the **+** button to add a new recipe with photo, ingredients, and steps.
4. Tap any recipe to view details, edit, or delete it.
5. Use the logout icon in the app bar to end the session.

## Notes
- Recipe categories are fetched from `assets/data/recipetypes.json` hosted in this repository; if unreachable, the app falls back to the bundled copy of the same file.
- Passwords are never stored in plain text — only their SHA-256 hash is persisted locally.