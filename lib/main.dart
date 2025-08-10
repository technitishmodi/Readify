import 'package:Readify/controller/Bookcontroller.dart';
import 'package:Readify/controller/theme_controller.dart';
import 'package:Readify/screen/homeScreen.dart';
import 'package:Readify/screen/signup_screen.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp();

  // Initialize Supabase
  await Supabase.initialize(
    url: 'https://lthmabtzeanqofhvxjxq.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imx0aG1hYnR6ZWFucW9maHZ4anhxIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDA4MjE0OTUsImV4cCI6MjA1NjM5NzQ5NX0.l0b06PjalyuhkjAJqw_9bbBmBv5j1qNTWU-MFKB5qSA',
  );

  // Initialize shared preferences and theme
  final prefs = await SharedPreferences.getInstance();
  final initialDarkMode = prefs.getBool('isDarkMode') ?? false;

  // Initialize GetX controllers
  Get.put(ThemeController());
  Get.put(BookController());

  runApp(MyApp(initialDarkMode: initialDarkMode));
}

class MyApp extends StatefulWidget {
  final bool initialDarkMode;

  const MyApp({super.key, required this.initialDarkMode});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final _auth = firebase_auth.FirebaseAuth.instance;
  late Stream<firebase_auth.User?> _authStateChanges;
  late ThemeController _themeController;
  late BookController _bookController;

  @override
  void initState() {
    super.initState();
    _authStateChanges = _auth.authStateChanges();
    _themeController = Get.find<ThemeController>();
    _bookController = Get.find<BookController>();
    _themeController.isDarkMode.value = widget.initialDarkMode;
  }

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Readify',
      theme: ThemeData.light().copyWith(
        primaryColor: const Color(0xFF4E6EFF),
        colorScheme: ColorScheme.fromSwatch().copyWith(
          secondary: const Color(0xFF4E6EFF),
        ),
        scaffoldBackgroundColor: const Color(0xFFF5F7FA),
      ),
      darkTheme: ThemeData.dark().copyWith(
        primaryColor: const Color(0xFF4E6EFF),
        colorScheme: ColorScheme.dark().copyWith(
          secondary: const Color(0xFF4E6EFF),
        ),
        scaffoldBackgroundColor: Colors.grey[900],
        cardColor: Colors.grey[800],
        textTheme: TextTheme(
          bodyLarge: TextStyle(color: Colors.grey[300]),
          bodyMedium: TextStyle(color: Colors.grey[300]),
        ),
      ),
      themeMode: _themeController.isDarkMode.value ? ThemeMode.dark : ThemeMode.light,
      home: StreamBuilder<firebase_auth.User?>(
        stream: _authStateChanges,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }

          final user = snapshot.data;
          if (user != null) {
            // Normal user flow only
            _bookController.fetchThoughts();
            return HomePage(
              userName: user.displayName ?? 'User',
              userEmail: user.email ?? 'No email',
              userPhoto: user.photoURL,
            );
          }

          return const SignupScreen();
        },
      ),
    );
  }
}