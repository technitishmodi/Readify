import 'package:Readify/controller/Bookcontroller.dart';
import 'package:Readify/controller/theme_controller.dart';
import 'package:Readify/controller/reading_progress_controller.dart';
import 'package:Readify/controller/smart_bookmark_controller.dart';
import 'package:Readify/screen/splash_screen.dart';
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
  Get.put(ReadingProgressController());
  Get.put(SmartBookmarkController());

  runApp(MyApp(initialDarkMode: initialDarkMode));
}

class MyApp extends StatefulWidget {
  final bool initialDarkMode;

  const MyApp({super.key, required this.initialDarkMode});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late ThemeController _themeController;

  @override
  void initState() {
    super.initState();
    _themeController = Get.find<ThemeController>();
    _themeController.isDarkMode.value = widget.initialDarkMode;
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() => GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Readify',
      theme: ThemeData.light(useMaterial3: true).copyWith(
        primaryColor: const Color(0xFF4E6EFF),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF4E6EFF),
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: const Color(0xFFF5F7FA),
      ),
      darkTheme: ThemeData.dark(useMaterial3: true).copyWith(
        primaryColor: const Color(0xFF4E6EFF),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF4E6EFF),
          brightness: Brightness.dark,
        ),
        scaffoldBackgroundColor: Colors.grey[900],
        cardColor: Colors.grey[800],
      ),
      themeMode: _themeController.isDarkMode.value ? ThemeMode.dark : ThemeMode.light,
      home: const SplashScreen(),
    ));
  }
}