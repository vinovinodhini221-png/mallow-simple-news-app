# Simple News App (Flutter)

A modern, responsive News application built with Flutter that fetches and displays spaceflight articles from the [Spaceflight News API v4](https://api.spaceflightnewsapi.net/v4/docs/).

Designed for **Android, iOS, tablets, and iPads**, following clean **MVVM architecture** and maintainable development practices.

---

## 📱 Features

### A. News List Screen – Discover

- **Search with Debounce:** Search articles by title or summary with a 500ms debounce to reduce unnecessary API requests.
- **Dynamic News-Site Filters:** Filter articles using news-site chips such as All, NASA, SpaceNews, Spaceflight Now, and Ars Technica, based on available API data.
- **Infinite Scroll Pagination:** Automatically loads additional articles when scrolling near the bottom.
- **Duplicate Prevention:** Prevents duplicate articles from appearing during pagination.
- **Pull-to-Refresh:** Refresh the news feed to retrieve the latest articles.
- **Responsive Layout:**
  - **Phones:** Single-column article cards with thumbnails, news-site labels, titles, and publication dates.
  - **Tablets and iPads:** Responsive two-column or three-column grid layout using `LayoutBuilder`.

### B. Article Detail Screen

- **Article Information:** Displays the article image, news-site name, publication date, title, and summary.
- **Read Full Article:** Opens the original article URL in an external browser using `url_launcher`.
- **Swipe Navigation:**
  - Supports horizontal swiping between articles.
  - Loads additional articles when reaching the end of the currently loaded list.
- **Bookmark Toggle:** Provides an in-app bookmark interaction with user feedback.

---

## 🏗️ Architecture Overview – MVVM

The application follows the **Model-View-ViewModel (MVVM)** architecture to maintain a clear separation of responsibilities.

```text
lib/
├── core/
│   ├── constants/       # API endpoints and application constants
│   ├── errors/          # Typed application exceptions
│   ├── network/         # Dio API client and error handling
│   ├── theme/           # Light and dark themes
│   └── utils/           # Date and time formatting utilities
│
├── data/
│   ├── models/          # ArticleModel and JSON deserialization
│   └── repositories/    # ArticleRepository and data handling
│
├── viewmodels/          # ArticleListViewModel and ArticleDetailViewModel
│
├── views/
│   ├── screens/         # Article list and detail screens
│   └── widgets/         # Reusable UI components
│
└── main.dart            # Application entry point and Provider setup
```

### Architecture Responsibilities

| Layer | Responsibility |
|---|---|
| Model | Represents article data and handles JSON parsing |
| View | Displays the user interface |
| ViewModel | Manages application state and UI-related logic |
| Repository | Handles article data retrieval and pagination |
| API Client | Manages HTTP requests and network errors |

---

## ⚡ State Management Choice

**Chosen Solution: Provider with ChangeNotifier**

### Why Provider?

1. **Lightweight:** Provider is suitable for applications of this scale without introducing unnecessary complexity.
2. **Separation of Concerns:** ViewModels manage application state independently of UI widgets.
3. **Testability:** ViewModels can be tested independently by using mock or fake repositories.
4. **Lifecycle Management:** Controllers, listeners, and debounce timers are disposed of appropriately to avoid memory leaks.

---

## 📦 Packages Used

| Package | Version | Purpose |
|---|---|---|
| provider | ^6.1.5+1 | State management and dependency injection |
| dio | ^5.11.1 | HTTP requests and network configuration |
| cached_network_image | ^4.0.7 | Image caching and loading placeholders |
| url_launcher | ^6.3.3 | Opening original article URLs |
| cupertino_icons | ^1.0.8 | iOS-style icons |

---

## 🛡️ Error Handling and Edge Cases

The application handles common real-world scenarios to provide a reliable user experience.

### 1. Loading, Empty, and Error States

- Loading indicators during initial data retrieval.
- Informative empty states when no articles or search results are available.
- Error screens with retry actions.

### 2. Network and Timeout Handling

- Handles network connectivity errors.
- Handles connection and receive timeouts.
- Uses typed application exceptions to provide user-friendly error messages.

### 3. Pagination Handling

- Prevents duplicate pagination requests.
- Avoids duplicate articles using article IDs.
- Displays a retry option when loading additional articles fails.

### 4. Missing or Null Fields

- Uses null-safe JSON deserialization.
- Provides fallback values for missing article information.
- Displays placeholder content when an article image is unavailable.

### 5. Dark Mode and Text Scaling

- Supports system-based theme selection.
- Provides light and dark themes.
- Uses flexible text layouts to reduce overflow issues with larger text sizes.

### 6. Controller and Resource Disposal

- Properly disposes of `TextEditingController`.
- Properly disposes of `ScrollController` and `PageController`.
- Cancels the search debounce timer during disposal.

---

## 🚀 Getting Started

### Prerequisites

- Flutter SDK compatible with the project's `pubspec.yaml`.
- Dart SDK version supported by the installed Flutter SDK.
- Android Studio or Xcode for emulator and simulator development.

### Installation

**1. Clone the repository**

```bash
git clone <your-repository-url>
cd mallow_tech
```

**2. Install dependencies**

```bash
flutter pub get
```

**3. Run the application**

```bash
flutter run
```

**4. Run the tests**

```bash
flutter test
```

**5. Analyze the project**

```bash
flutter analyze
```

---

## 🧪 Testing

The project includes unit tests and widget tests covering the main application components.

Run the complete test suite:

```bash
flutter test
```

### Test Coverage

| Test File | Purpose |
|---|---|
| `test/models/article_model_test.dart` | Tests JSON parsing, null safety, fallback values, and date parsing |
| `test/repositories/article_repository_test.dart` | Tests article retrieval, pagination, and single-article fetching |
| `test/viewmodels/article_list_viewmodel_test.dart` | Tests loading, success, error, and category-filter states |
| `test/widget_test.dart` | Tests UI elements such as the header, search bar, filter chips, and article cards |

---

## 🌐 API Reference

**Spaceflight News API v4**

- API Documentation: https://api.spaceflightnewsapi.net/v4/docs/
- Articles Endpoint: https://api.spaceflightnewsapi.net/v4/articles/

The application retrieves article information from the Spaceflight News API and displays it through the news list and article detail screens.

---

## 📝 Project Information

**Project:** Simple News App  
**Platform:** Flutter – Android, iOS, and Tablet  
**Architecture:** MVVM  
**State Management:** Provider / ChangeNotifier  
**Networking:** Dio  
**API:** Spaceflight News API v4

---

## 👩‍💻 Development Notes

AI tools were used as development assistance for project structuring, implementation guidance, debugging, code improvements, and documentation.

The generated code was reviewed, the application was run, and functionality was tested during development. AI was used as a supporting tool rather than as a replacement for reviewing and validating the implementation.

