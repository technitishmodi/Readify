# 📚 Readify – eBook Sharing App

Readify is a modern, community-driven mobile application built with Flutter and Dart. It enables users to upload, share, and read eBooks (PDFs) in a collaborative environment. The app leverages Firebase and Supabase for authentication, real-time data sync, and file storage, providing a seamless and secure reading experience.

---

## 🚀 Features
- **User Authentication**: Secure login with Google Sign-In (Firebase Auth)
- **Upload eBooks**: Add eBooks in PDF format, with cover images
- **Read eBooks**: In-app PDF viewer with navigation, bookmarks, and dark mode
- **Text-to-Speech**: Listen to eBooks using integrated TTS
- **Community Thoughts**: Share and view thoughts with the community
- **Book Requests**: Request new books from the community
- **Personal Library**: Manage your own uploaded books
- **Trending Books**: Discover popular books among users
- **Responsive UI**: Clean, minimal, and adaptive design

---

## 🏗️ Architecture
- **Frontend**: Flutter (Dart), GetX for state management
- **Backend**: Firebase (Auth, Firestore), Supabase (Storage)
- **Models**: Book, ThoughtPost, BookRequest
- **Controllers**: BookController, PdfController, PdfTtsController, ThemeController

---

## 📂 Project Structure
```
lib/
  main.dart
  controller/
    Bookcontroller.dart
    pdfCotroller.dart
    theme_controller.dart
  models/
    bookmodel.dart
  Booklisten/
    PdfTtsController.dart
    PdfListeningScreen.dart
  screen/
    homeScreen.dart
    signup_screen.dart
  addpage/
    Addnewbook.dart
  bookdetails/
    bookdetail.dart
  bookpage/
    boopageRead.dart
  profilepage/
    ProFilepage.dart
    TrendingBooksPage.dart
  th&&re/
    thoughts_page.dart
    request_book.dart
```

---

## 🧑‍💻 Key Components

### Controllers
- **BookController**: Handles book CRUD, uploads, requests, and community thoughts
- **PdfController**: Manages PDF viewing and bookmarks
- **PdfTtsController**: Provides text-to-speech for PDFs
- **ThemeController**: Manages light/dark mode and persists user preference

### Models
- **Bookmodel**: Represents book metadata and storage info
- **ThoughtPost**: Community posts with likes and user info
- **BookRequest**: User requests for new books

---

## 📖 Usage
1. **Sign Up / Log In**: Use Google Sign-In to access the app
2. **Upload Book**: Add a new book with PDF and cover image
3. **Read Book**: Open any book, use bookmarks, and listen with TTS
4. **Share Thoughts**: Post and like thoughts in the community
5. **Request Book**: Ask for books you want to read
6. **Manage Library**: View and manage your uploaded books

---

## 🛠️ Setup & Installation
1. Clone the repository
2. Run `flutter pub get`
3. Configure Firebase and Supabase (update keys in `main.dart`)
4. Run `flutter run` on your device/emulator

---

## 📝 Example Code
```dart
// main.dart (entry point)
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await Supabase.initialize(
    url: 'YOUR_SUPABASE_URL',
    anonKey: 'YOUR_SUPABASE_ANON_KEY',
  );
  runApp(MyApp());
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
- [Flutter](https://flutter.dev/)
- [Firebase](https://firebase.google.com/)
- [Supabase](https://supabase.com/)
- [Syncfusion Flutter PDF Viewer](https://pub.dev/packages/syncfusion_flutter_pdfviewer)
- [GetX](https://pub.dev/packages/get)
