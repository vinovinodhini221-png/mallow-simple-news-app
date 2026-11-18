# Simple News App (Flutter)

A modern, responsive News application built with Flutter that fetches and displays real-time spaceflight articles from the [Spaceflight News API (v4)](https://api.spaceflightnewsapi.net/v4/docs/).

Designed for **Android, iOS, tablets, and iPads**, following clean **MVVM architecture** and production-grade engineering practices.

---

## 📱 Features

### A. List Screen ("Discover")
- **Search with Debounce**: Real-time article search by title and summary with a 500ms debounce to prevent unnecessary network requests.
- **Category Filter Chips**: Filter articles by popular news sites (`All`, `NASA`, `SpaceNews`, `Spaceflight Now`, `Ars Technica`, etc.).
- **Infinite Scroll Pagination**: Automatically loads subsequent pages as the user scrolls near the bottom without duplicate items.
- **Pull-to-Refresh**: Seamless refresh indicator to fetch the latest news feed.
- **Responsive Layout**:
  - **Phones**: Single-column horizontal cards with rounded thumbnails, site tags, titles, and dates matching the reference design.
  - **Tablets / iPads**: 2-column or 3-column responsive grid layout using `LayoutBuilder`.

### B. Detail Screen
- **Full Article Information**: Displays hero image, news site with verified badge, publish date, full title, and detailed summary.
- **Read Full Article**: Opens the source article in an external browser using `url_launcher`.
- **Swipe Navigation (Gmail-style)**:
  - Supports horizontal swipe gestures between news articles.
  - Automatically prefetches the next page when reaching the end of the loaded articles.
- **Bookmark Toggle**: In-app interaction with user feedback.

---

## 🏗️ Architecture Overview (MVVM)

The application follows the **Model-View-ViewModel (MVVM)** pattern with strict separation of concerns:

```
lib/
├── core/
│   ├── constants/       # API endpoints, URLs, app-wide strings
│   ├── errors/          # Typed domain exceptions (Network, Timeout, Server, Client)
│   ├── network/         # ApiClient wrapping Dio with custom error mapping
│   ├── theme/           # Light and dark Material 3 themes
│   └── utils/           # Date and relative time formatters
│
├── data/
│   ├── models/          # ArticleModel with null-safe JSON deserialization
│   └── repositories/    # ArticleRepository with pagination and filtering logic
│
├── viewmodels/          # ArticleListViewModel & ArticleDetailViewModel (ChangeNotifier)
│
├── views/
│   ├── screens/         # ArticleListScreen & ArticleDetailScreen
│   └── widgets/         # Reusable ArticleCard, EmptyWidget, AppErrorWidget, LoadingWidget
│
└── main.dart            # App entrypoint and MultiProvider setup
```

---

## ⚡ State Management Choice & Justification

**Chosen Solution**: `Provider` with `ChangeNotifier`

### Justification:
1. **Lightweight & Idiomatic**: Recommended by the Flutter team for applications of this scale, providing reactive state updates without unnecessary boilerplate.
2. **Clear Separation**: ViewModels (`ArticleListViewModel`, `ArticleDetailViewModel`) encapsulate UI logic and state while staying decoupled from Flutter UI widgets.
3. **Testability**: ViewModels can be tested easily in isolation using pure Dart unit tests by passing a mock/fake repository.
4. **Lifecycle & Memory Safety**: Controllers, debouncers, and listeners are cleanly disposed in ViewModel/State lifecycle hooks to prevent memory leaks.

---

## 📦 Packages Used

| Package | Version | Purpose |
| :--- | :--- | :--- |
| `provider` | `^6.1.5+1` | Reactive state management and dependency injection |
| `dio` | `^5.11.1` | HTTP client with configurable timeouts and request interceptors |
| `cached_network_image` | `^4.0.7` | Image caching with smooth placeholders and error handling |
| `url_launcher` | `^6.3.3` | Opening original article URLs in the external browser |
| `cupertino_icons` | `^1.0.8` | Standard iOS-style icon assets |

---

## 🛡️ Production Scenarios Handled

1. **Loading, Empty, & Error States**:
   - Centered shimmer/spinners for initial loading.
   - Informative empty view for searches with no matches, with a refresh option.
   - Dedicated error views with actionable "Try Again" buttons.
2. **Offline & Timeout Handling**:
   - Typed exceptions: `NetworkException` (no internet) and `TimeoutException` (server delay).
   - User-friendly error messages instead of raw technical stack traces.
3. **Pagination Errors & Duplicate Loads**:
   - Displays a dedicated "Retry loading more" footer if subsequent pages fail.
   - Deduplicates incoming articles by ID (`Set<int>`) to prevent duplicate cards.
4. **Missing or Null Fields**:
   - `ArticleModel` gracefully defaults missing titles, URLs, summaries, and dates.
   - Missing images fallback to an elegant placeholder container.
5. **Dark Mode & Dynamic Text Scaling**:
   - Full support for `ThemeMode.system`, `lightTheme`, and `darkTheme`.
   - Flexible text constraints (`maxLines`, `overflow: TextOverflow.ellipsis`, `SingleChildScrollView`) prevent overflow when text size is scaled.
6. **Controller Disposal**:
   - `TextEditingController`, `ScrollController`, `PageController`, and search `_debounceTimer` are disposed in `dispose()`.

---

## 🚀 Getting Started & Setup

### Prerequisites
- Flutter SDK `^3.14.0` or later
- Dart SDK `^3.5.0`
- Android Studio / Xcode (for simulators/emulators)

### Installation
1. Clone the repository:
   ```bash
   git clone <repo-url>
   cd mallow_tech
   ```
2. Install dependencies:
   ```bash
   flutter pub get
   ```
3. Run the test suite:
   ```bash
   flutter test
   ```
4. Run the application:
   ```bash
   flutter run
   ```

---

## 🧪 Testing

The project includes unit tests for Models, Repositories, and ViewModels, as well as UI widget tests:

```bash
flutter test
```

- **`test/models/article_model_test.dart`**: Tests null-safety, default fallbacks, and ISO date parsing.
- **`test/repositories/article_repository_test.dart`**: Tests pagination parsing and single article fetching.
- **`test/viewmodels/article_list_viewmodel_test.dart`**: Tests state transitions (loading, success, error, category filter).
- **`test/widget_test.dart`**: Tests header rendering, search bar, chips, and article cards.
