import 'package:Readify/profilepage/ProFilepage.dart';
import 'package:Readify/screen/admin_page.dart';
import 'package:Readify/screen/signup_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AdminHomeScreen extends StatefulWidget {
  final String userName;
  final String userEmail;
  final String? userPhoto;

  const AdminHomeScreen({
    super.key,
    required this.userName,
    required this.userEmail,
    this.userPhoto,
  });

  @override
  State<AdminHomeScreen> createState() => _AdminHomeScreenState();
}

class _AdminHomeScreenState extends State<AdminHomeScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );
    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  Future<void> _signOut() async {
    try {
      // Show loading indicator
      Get.dialog(
        const Center(
          child: CircularProgressIndicator(),
        ),
        barrierDismissible: false,
      );

      // Sign out from Google first
      await GoogleSignIn().signOut();
      
      // Sign out from Firebase
      await FirebaseAuth.instance.signOut();
      
      // Add small delay to ensure sign out completes
      await Future.delayed(const Duration(milliseconds: 500));
      
      // Clear any cached data (non-critical operation)
      try {
        await FirebaseFirestore.instance.clearPersistence();
      } catch (e) {
        // Ignore cache clear errors as they're not critical
        print('Cache clear error (non-critical): $e');
      }
      
      // Close loading dialog
      if (Get.isDialogOpen ?? false) {
        Get.back();
      }
      
      // Add another small delay before navigation
      await Future.delayed(const Duration(milliseconds: 200));
      
      // Navigate to signup screen using GetX with complete stack replacement
      Get.offAll(() => const SignupScreen());
      
    } catch (e) {
      // Close loading dialog if it's open
      if (Get.isDialogOpen ?? false) {
        Get.back();
      }
      
      // Show error message
      Get.snackbar(
        'Sign Out Error',
        'Failed to sign out: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: const Text(
          'Admin Panel',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        elevation: 0,
        centerTitle: true,
      ),
      drawer: NavigationDrawer(
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  colorScheme.primary,
                  colorScheme.primary.withOpacity(0.8),
                ],
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 32,
                  backgroundColor: colorScheme.surface,
                  child: widget.userPhoto != null
                      ? ClipOval(
                          child: Image.network(
                            widget.userPhoto!,
                            width: 64,
                            height: 64,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Icon(
                              Icons.admin_panel_settings,
                              color: colorScheme.primary,
                              size: 32,
                            ),
                          ),
                        )
                      : Icon(
                          Icons.admin_panel_settings,
                          color: colorScheme.primary,
                          size: 32,
                        ),
                ),
                const SizedBox(height: 12),
                Text(
                  widget.userName,
                  style: TextStyle(
                    color: colorScheme.onPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Administrator',
                  style: TextStyle(
                    color: colorScheme.onPrimary.withOpacity(0.8),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.admin_panel_settings),
            title: const Text('Admin Dashboard'),
            onTap: () {
              Navigator.pop(context);
              Get.to(() => const AdminPage());
            },
          ),
          ListTile(
            leading: const Icon(Icons.library_books_outlined),
            title: const Text('My Library'),
            onTap: () {
              Navigator.pop(context);
              Get.to(() => Profilepage(
                userName: widget.userName,
                userEmail: widget.userEmail,
                userPhoto: widget.userPhoto,
              ));
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout_outlined),
            title: const Text('Sign Out'),
            onTap: _signOut,
          ),
        ],
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Welcome, ${widget.userName}',
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Administrator Dashboard',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: colorScheme.onSurface.withOpacity(0.7),
                ),
              ),
              const SizedBox(height: 32),
              Expanded(
                child: GridView.count(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  children: [
                    _buildAdminCard(
                      context,
                      'Admin Dashboard',
                      'Manage books, users, and analytics',
                      Icons.admin_panel_settings,
                      colorScheme.primary,
                      () => Get.to(() => const AdminPage()),
                    ),
                    _buildAdminCard(
                      context,
                      'My Library',
                      'View your personal book collection',
                      Icons.library_books,
                      colorScheme.secondary,
                      () => Get.to(() => Profilepage(
                        userName: widget.userName,
                        userEmail: widget.userEmail,
                        userPhoto: widget.userPhoto,
                      )),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAdminCard(
    BuildContext context,
    String title,
    String description,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  size: 28,
                  color: color,
                ),
              ),
              const SizedBox(height: 12),
              Flexible(
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(height: 6),
              Flexible(
                child: Text(
                  description,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                    fontSize: 11,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
