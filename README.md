# 📚 Readify – eBoo### 📚 Reading Features
- **Advanced PDF Viewer**: 
  - Page navigation & zooming
  - Reading progress tracking
  - Background color customization
  - Bookmark management
- **Intelligent Text-to-Speech**:
  - Smart text chunking
  - Multiple voice options
  - Speed & pitch control
  - Background playback

### 📊 Smart Reading Analytics
- **Reading Progress Tracking**:
  - Reading speed analysis
  - Time spent per session
  - Daily/weekly/monthly goals
  - Progress visualization
- **AI-Powered Insights**:
  - Reading pattern analysis
  - Comprehension metrics
  - Personalized recommendations
  - Reading habit optimization
- **Goal Setting & Achievement**:
  - Custom reading targets
  - Achievement badges
  - Streak tracking
  - Progress milestones

### 🔖 Smart Bookmarking System
- **Intelligent Categorization**:
  - Auto-categorization of bookmarks
  - Context-aware tagging
  - Important passage detection
  - Custom categories
- **Enhanced Note Taking**:
  - Rich text annotations
  - Voice notes support
  - Image attachments
  - Tag-based organization
- **AI-Powered Features**:
  - Related content suggestions
  - Theme identification
  - Key concept extraction
  - Cross-book connections

### 📖 Library Management

Readify is a modern, community-driven mobile application built with Flutter and Dart. It enables users to upload, share, and read eBooks (PDFs) in a collaborative environment. The app leverages Firebase for authentication and data storage, providing a seamless and secure reading experience with features like text-to-speech and community engagement.

![Flutter Version](https://img.shields.io/badge/Flutter-3.0+-blue.svg)
![Dart Version](https://img.shields.io/badge/Dart-3.0+-blue.svg)
![License](https://img.shields.io/badge/license-MIT-green.svg)

---

## 🚀 Key Features

### 📱 User Experience
- **Seamless Authentication**: Google Sign-In integration
- **Intuitive Navigation**: Bottom navigation with smooth transitions
- **Dynamic Theming**: Light/Dark mode with Material You support
- **Responsive Design**: Adaptive layouts for all screen sizes
- **Custom Animations**: Enhanced user interaction feedback

### � Reading Features
- **Advanced PDF Viewer**: 
  - Page navigation & zooming
  - Reading progress tracking
  - Background color customization
  - Bookmark management
- **Intelligent Text-to-Speech**:
  - Smart text chunking
  - Multiple voice options
  - Speed & pitch control
  - Background playback

### 📖 Library Management
- **eBook Upload System**:
  - PDF file support
  - Cover image upload
  - Metadata management
  - Privacy controls
- **Smart Organization**:
  - Category-based sorting
  - Search functionality
  - Reading history
  - Favorites system

### 🤝 Community Features
- **Interactive Thoughts**:
  - Book discussions
  - User comments
  - Like system
- **Book Requests**:
  - Request tracking
  - Community responses
  - Status updates
- **Trending Section**:
  - Popular books
  - New additions
  - User recommendations

---

## 🏗️ Architecture & Technical Stack

### Frontend
- **Framework**: Flutter (Dart) for cross-platform development
- **State Management**: GetX for reactive state management and dependency injection
- **UI/UX**: Material Design 3 with dynamic theming
- **PDF Rendering**: SyncFusion Flutter PDF viewer for optimized rendering
- **Animations**: Custom animations for enhanced user experience

### Backend Services
- **Authentication**: Firebase Auth with Google Sign-In
- **Database**: Cloud Firestore with real-time updates
- **Storage**: Firebase Storage for PDFs and images
- **Analytics**: Firebase Analytics for user engagement tracking

### Core Features
- **PDF Processing**: 
  - Efficient chunked reading
  - Progress tracking
  - Smart bookmarking system
  - Content analysis engine
- **Reading Intelligence**: 
  - AI-powered insights
  - Reading pattern analysis
  - Comprehension tracking
  - Performance metrics
- **Smart Bookmarking**: 
  - Context-aware categorization
  - Auto-tagging system
  - Cross-reference management
  - Intelligent suggestions
- **Text-to-Speech**: 
  - Adaptive chunk management
  - Multi-language support
  - Customizable speech parameters
- **Reading Analytics**:
  - Goal tracking system
  - Progress visualization
  - Achievement management
  - Habit analysis
- **Data Management**:
  - Real-time synchronization
  - Offline support
  - Cached reading progress
  - Cross-device sync

---

## 📂 Project Structure
```
lib/
├── main.dart               # Application entry point
├── controller/            # GetX controllers
│   ├── book_controller.dart    # Book CRUD operations
│   ├── pdf_controller.dart     # PDF viewer handling
│   ├── tts_controller.dart     # Text-to-Speech engine
│   ├── theme_controller.dart   # Theme management
│   ├── bookmark_controller.dart # Bookmark system
│   ├── reading_progress_controller.dart
│   └── smart_bookmark_controller.dart
├── models/               # Data models
│   ├── book_model.dart  # Book metadata and storage
│   ├── thought_post.dart # Community interactions
│   └── book_request.dart # Book requests
├── screen/              # Main screens
│   ├── splash_screen.dart
│   ├── onboarding_screen.dart
│   ├── home_screen.dart
│   ├── signup_screen.dart
│   └── admin_page.dart
├── bookpage/           # Reading features
│   ├── book_page_read.dart
│   └── listening_screen.dart
├── bookdetails/       # Book information
│   └── book_detail.dart
├── components/        # Reusable widgets
│   ├── book_card.dart
│   └── book_card123.dart
├── th&&re/           # Community features
│   ├── thoughts_page.dart
│   └── request_book.dart
└── utils/            # Helper functions
```

---

## 🧑‍💻 Key Components

### Controllers
- **BookController**: 
  - Book CRUD operations with Firebase
  - File uploads (PDF/Images)
  - Community features (thoughts/requests)
  - User library management
- **TtsController**: 
  - Advanced text chunking for long texts
  - Multi-language support
  - Customizable speech parameters
  - Error handling and recovery
- **SmartBookmarkController**: 
  - AI-powered bookmark categorization
  - Intelligent tag suggestions
  - Cross-reference management
  - Content analysis and insights
  - Contextual note organization
- **ReadingProgressController**: 
  - Real-time progress tracking
  - Reading velocity analysis
  - Goal management system
  - Achievement tracking
  - Reading session analytics
- **ReadingAnalyticsController**:
  - Pattern recognition
  - Reading habit analysis
  - Performance metrics
  - Goal progress monitoring
  - Custom insights generation
- **ReadingGoalsController**:
  - Goal setting and tracking
  - Milestone management
  - Streak monitoring
  - Achievement rewards
  - Progress visualization

### Models
- **Bookmodel**: 
  - Book metadata
  - Storage URLs
  - Visibility controls
  - Category management
- **ThoughtPost**: 
  - User interactions
  - Community engagement
  - Timestamp tracking
- **BookRequest**: 
  - Request management
  - Status tracking
  - User attribution

---

## 📖 Usage
1. **Sign Up / Log In**: Use Google Sign-In to access the app
2. **Upload Book**: Add a new book with PDF and cover image
3. **Read Book**: Open any book, use bookmarks, and listen with TTS
4. **Share Thoughts**: Post and like thoughts in the community
5. **Request Book**: Ask for books you want to read
6. **Manage Library**: View and manage your uploaded books

---

## 🛠️ Development Setup

### Prerequisites
- Flutter SDK (3.0+)
- Dart SDK (3.0+)
- Firebase CLI
- Android Studio / VS Code
- Git

### Installation Steps

1. **Clone & Setup**
   ```bash
   # Clone the repository
   git clone https://github.com/technitishmodi/Readify.git
   cd Readify

   # Install dependencies
   flutter pub get
   ```

2. **Firebase Configuration**
   ```bash
   # Install Firebase CLI
   npm install -g firebase-tools

   # Login to Firebase
   firebase login

   # Initialize Firebase
   firebase init
   ```

3. **Configure Firebase Services**
   - Create a new Firebase project
   - Enable required services:
     - Authentication (Google Sign-In)
     - Cloud Firestore
     - Storage
   - Download and add configuration files:
     - `google-services.json` for Android
     - `GoogleService-Info.plist` for iOS

4. **Environment Setup**
   - Update Firebase config in `lib/main.dart`
   - Configure build settings for platforms:
     ```bash
     # Android
     flutter build apk --release

     # iOS
     flutter build ios --release
     ```

5. **Run Development Server**
   ```bash
   # Start in debug mode
   flutter run

   # Start with specific device
   flutter run -d <device-id>
   ```

---

## 📝 Example Code

### Initialize Firebase and App
```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  // Initialize controllers
  Get.put(ThemeController());
  Get.put(BookController());
  
  runApp(MyApp());
}
```

### Text-to-Speech Implementation
```dart
class TtsController extends GetxController {
  FlutterTts? flutterTts;
  var isPlaying = false.obs;
  var currentText = ''.obs;

  Future<void> speak(String text) async {
    if (!isInitialized.value) await _initTts();
    
    try {
      await flutterTts!.stop();
      currentText.value = text;
      
      if (text.length > 4000) {
        await _speakInChunks(text);
      } else {
        await flutterTts!.speak(text);
      }
    } catch (e) {
      isPlaying.value = false;
    }
  }
}
```

---

## 📸 Screenshots
- Login Screen
- Home Screen
- Book Detail
- PDF Reader
- Community Thoughts

---

## 📄 License
This project is for educational purposes only.

---

## 🙏 Acknowledgements

### Core Technologies
- [Flutter](https://flutter.dev/) - UI framework
- [Firebase](https://firebase.google.com/) - Backend services
- [GetX](https://pub.dev/packages/get) - State management

### Key Packages
- [syncfusion_flutter_pdfviewer](https://pub.dev/packages/syncfusion_flutter_pdfviewer) - PDF viewing
- [flutter_tts](https://pub.dev/packages/flutter_tts) - Text-to-speech
- [firebase_auth](https://pub.dev/packages/firebase_auth) - Authentication
- [cloud_firestore](https://pub.dev/packages/cloud_firestore) - Database
- [firebase_storage](https://pub.dev/packages/firebase_storage) - File storage

## 📱 Platform Support
- ✅ Android
- ✅ iOS
- ✅ Web (beta)
- 🚧 Desktop (in progress)
