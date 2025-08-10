// import 'package:e_book/addpage/Addnewbook.dart';
// import 'package:e_book/bookdetails/bookdetail.dart';
// import 'package:e_book/components/bookcard123.dart';
// import 'package:e_book/controller/Bookcontroller.dart';
// import 'package:e_book/screen/signup_screen.dart';
import 'package:Readify/addpage/Addnewbook.dart';
import 'package:Readify/bookdetails/bookdetail.dart';
import 'package:Readify/components/bookcard123.dart';
import 'package:Readify/controller/Bookcontroller.dart';
import 'package:Readify/screen/signup_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart'; // Add this if using Google Sign-In

class Profilepage extends StatelessWidget {
  final String userName;
  final String userEmail;
  final BookController bookController;
  final String? userPhoto;

  Profilepage({
    super.key,
    required this.userName,
    required this.userEmail,
    this.userPhoto,
  }) : bookController = Get.find<BookController>();

  Future<void> _signOut() async {
    final result = await Get.dialog<bool>(
      AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Text(
          "Sign Out",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: const Text("Are you sure you want to sign out?"),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () => Get.back(result: true),
            child: const Text(
              "Sign Out",
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );

    if (result == true) {
      try {
        // Show loading indicator
        Get.dialog(
          const Center(child: CircularProgressIndicator()),
          barrierDismissible: false,
        );

        // Sign out from Firebase
        await FirebaseAuth.instance.signOut();

        // Sign out from Google (if using Google Sign-In)
        await GoogleSignIn().signOut();

        // Close loading indicator
        Get.back();

        // Navigate to SignupScreen and clear navigation stack
        Get.offAll(() => const SignupScreen());
      } catch (e) {
        // Close loading indicator if still open
        if (Get.isDialogOpen ?? false) Get.back();

        Get.snackbar(
          "Error",
          "Failed to sign out: ${e.toString()}",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red[100],
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () => Get.to(() => const AddNewbook()),
        backgroundColor: Colors.white,
        child: const Icon(Icons.add, color: Colors.blue),
      ),
      body: Obx(() {
        if (bookController.isUserBooksLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        return CustomScrollView(
          slivers: [
            SliverAppBar(
              expandedHeight: 330,
              flexibleSpace: FlexibleSpaceBar(
                background: Container(
                  color: Colors.blueAccent,
                  padding: const EdgeInsets.only(top: 50),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 20),
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(100),
                          border: Border.all(width: 2, color: Colors.white),
                        ),
                        child: Container(
                          width: 120,
                          height: 120,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(100),
                            child: userPhoto != null
                                ? Image.network(
                                    userPhoto!,
                                    fit: BoxFit.cover,
                                    errorBuilder:
                                        (context, error, stackTrace) =>
                                            _buildDefaultAvatar(),
                                  )
                                : _buildDefaultAvatar(),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        userName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        userEmail,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildSignOutButton(),
                    ],
                  ),
                ),
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.settings, color: Colors.white),
                  onPressed: () {
                    // Add settings navigation if needed
                  },
                ),
              ],
            ),
            SliverPadding(
              padding: const EdgeInsets.all(16),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final book = bookController.userBooks[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: Bookcard123(
                        title: book.title ?? 'No Title',
                        auther: book.auther ?? 'Unknown Author',
                        coverUrl: book.imageUrl ?? '',
                        price: (book.price ?? 0).toString(),
                        rating: (book.ratings ?? 0).toString(),
                        bookUrl: book.bookUrl ?? '',
                        description: book.descriptions ??
                            'No description available', 
                        aboutAuthor: book.aboutAuthor ??
                            'No information about author', 
                        onTap: () => Get.to(() => Bookdetail(
                              coverUrl: book.bookUrl ?? '',
                              title: book.title ?? '',
                              author: book.auther ?? '',
                              description: book.descriptions ?? '',
                              aboutAuthor: book.aboutAuthor ?? '',
                              imageUrl: book.imageUrl ?? '',
                            )),
                      ),
                    );
                  },
                  childCount: bookController.userBooks.length,
                ),
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildSignOutButton() {
    return ElevatedButton.icon(
      onPressed: _signOut,
      icon: const Icon(Icons.logout, size: 18),
      label: const Text("Sign Out"),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        foregroundColor: Colors.red,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        elevation: 2,
      ),
    );
  }

  Widget _buildDefaultAvatar() {
    return Container(
      color: Colors.blue[200],
      child: const Center(
        child: Icon(
          Icons.person,
          size: 50,
          color: Colors.white,
        ),
      ),
    );
  }
}
