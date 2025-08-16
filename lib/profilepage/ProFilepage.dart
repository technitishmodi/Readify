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
import 'package:cloud_firestore/cloud_firestore.dart';
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
              sliver: bookController.userBooks.isEmpty
                  ? SliverToBoxAdapter(
                      child: Container(
                        height: 200,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.1),
                              blurRadius: 10,
                              spreadRadius: 2,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.library_books_outlined,
                                size: 64,
                                color: Colors.grey[400],
                              ),
                              const SizedBox(height: 16),
                              Text(
                                "No books uploaded yet",
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 18,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                "Tap the + button to add your first book",
                                style: TextStyle(
                                  color: Colors.grey[500],
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    )
                  : SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final book = bookController.userBooks[index];
                          final currentUser = FirebaseAuth.instance.currentUser;
                          final isOwner = currentUser != null && 
                                         book.uploaderId == currentUser.uid;
                          
                          return Container(
                            margin: const EdgeInsets.only(bottom: 16),
                            child: InkWell(
                              borderRadius: BorderRadius.circular(16),
                              onTap: () {
                                Get.to(() => Bookdetail(
                                      coverUrl: book.bookUrl ?? '',
                                      title: book.title ?? '',
                                      author: book.auther ?? '',
                                      description: book.descriptions ?? '',
                                      aboutAuthor: book.aboutAuthor ?? '',
                                      imageUrl: book.imageUrl ?? '',
                                    ));
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.grey.withOpacity(0.1),
                                      blurRadius: 10,
                                      spreadRadius: 2,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Stack(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.all(16),
                                      child: Row(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          // Book Cover with modern styling
                                          Container(
                                            width: 90,
                                            height: 130,
                                            decoration: BoxDecoration(
                                              borderRadius: BorderRadius.circular(8),
                                              color: Colors.grey[100],
                                              image: book.imageUrl != null && book.imageUrl!.isNotEmpty
                                                  ? DecorationImage(
                                                      image: NetworkImage(book.imageUrl!),
                                                      fit: BoxFit.cover,
                                                    )
                                                  : null,
                                            ),
                                            child: book.imageUrl == null || book.imageUrl!.isEmpty
                                                ? const Center(
                                                    child: Icon(Icons.book, 
                                                      size: 40, 
                                                      color: Colors.grey),
                                                  )
                                                : null,
                                          ),
                                          const SizedBox(width: 16),
                                          // Book Details
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  book.title ?? 'No Title',
                                                  style: const TextStyle(
                                                    fontSize: 17,
                                                    fontWeight: FontWeight.w600,
                                                    height: 1.3,
                                                  ),
                                                  maxLines: 2,
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                                const SizedBox(height: 8),
                                                Text(
                                                  "By ${book.auther ?? 'Unknown Author'}",
                                                  style: TextStyle(
                                                    fontSize: 14,
                                                    color: Colors.grey[600],
                                                  ),
                                                ),
                                                const SizedBox(height: 12),
                                                Row(
                                                  children: [
                                                    Container(
                                                      padding: const EdgeInsets.symmetric(
                                                          horizontal: 8, vertical: 4),
                                                      decoration: BoxDecoration(
                                                        color: Colors.amber.withOpacity(0.2),
                                                        borderRadius: BorderRadius.circular(4),
                                                      ),
                                                      child: Row(
                                                        mainAxisSize: MainAxisSize.min,
                                                        children: [
                                                          const Icon(Icons.star,
                                                            color: Colors.amber,
                                                            size: 16),
                                                          const SizedBox(width: 4),
                                                          Text(
                                                            (double.tryParse(book.ratings ?? '0')?.toStringAsFixed(1)) ?? '0.0',
                                                            style: const TextStyle(
                                                              fontWeight: FontWeight.w600,
                                                              fontSize: 13,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                    const Spacer(),
                                                    Text(
                                                      "\$${book.price?.toStringAsFixed(2) ?? '0.00'}",
                                                      style: const TextStyle(
                                                        fontWeight: FontWeight.w700,
                                                        fontSize: 16,
                                                        color: Color(0xFF4E6EFF),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    if (isOwner)
                                      Positioned(
                                        top: 8,
                                        right: 8,
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Container(
                                              decoration: BoxDecoration(
                                                color: Colors.blue,
                                                borderRadius: BorderRadius.circular(20),
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: Colors.blue.withOpacity(0.3),
                                                    blurRadius: 4,
                                                    spreadRadius: 1,
                                                  ),
                                                ],
                                              ),
                                              child: IconButton(
                                                icon: const Icon(Icons.edit, 
                                                    color: Colors.white, size: 16),
                                                onPressed: () => _showEditDialog(book),
                                                padding: const EdgeInsets.all(6),
                                                constraints: const BoxConstraints(
                                                  minWidth: 32,
                                                  minHeight: 32,
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 6),
                                            Container(
                                              decoration: BoxDecoration(
                                                color: Colors.red,
                                                borderRadius: BorderRadius.circular(20),
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: Colors.red.withOpacity(0.3),
                                                    blurRadius: 4,
                                                    spreadRadius: 1,
                                                  ),
                                                ],
                                              ),
                                              child: IconButton(
                                                icon: const Icon(Icons.delete, 
                                                    color: Colors.white, size: 16),
                                                onPressed: () => _showDeleteDialog(book),
                                                padding: const EdgeInsets.all(6),
                                                constraints: const BoxConstraints(
                                                  minWidth: 32,
                                                  minHeight: 32,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                  ],
                                ),
                              ),
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

  void _showEditDialog(dynamic book) {
    // Populate the form with current book data
    bookController.title.text = book.title ?? '';
    bookController.authorname.text = book.auther ?? '';
    bookController.des.text = book.descriptions ?? '';
    bookController.aboutauthor.text = book.aboutAuthor ?? '';
    
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Text(
          "Edit Book",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildEditTextField("Title", bookController.title),
              const SizedBox(height: 12),
              _buildEditTextField("Author", bookController.authorname),
              const SizedBox(height: 12),
              _buildEditTextField("Description", bookController.des, maxLines: 3),
              const SizedBox(height: 12),
              _buildEditTextField("About Author", bookController.aboutauthor, maxLines: 2),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              bookController.title.clear();
              bookController.authorname.clear();
              bookController.des.clear();
              bookController.aboutauthor.clear();
              Get.back();
            },
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () async {
              await _updateBook(book);
              Get.back();
            },
            child: const Text("Update"),
          ),
        ],
      ),
    );
  }

  Future<void> _updateBook(dynamic book) async {
    try {
      await FirebaseFirestore.instance.collection('Book').doc(book.id).update({
        'title': bookController.title.text,
        'auther': bookController.authorname.text,
        'descriptions': bookController.des.text,
        'aboutAuthor': bookController.aboutauthor.text,
      });
      
      // Clear form
      bookController.title.clear();
      bookController.authorname.clear();
      bookController.des.clear();
      bookController.aboutauthor.clear();
      
      // Refresh user books
      bookController.fetchUserBooks();
      
      Get.snackbar(
        "Success",
        "Book updated successfully",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        "Error",
        "Failed to update book: ${e.toString()}",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  void _showDeleteDialog(dynamic book) {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Text(
          "Delete Book",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.red,
          ),
        ),
        content: Text(
          "Are you sure you want to delete '${book.title}'? This action cannot be undone.",
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () async {
              await _deleteBook(book);
              Get.back();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text("Delete"),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteBook(dynamic book) async {
    try {
      await FirebaseFirestore.instance.collection('Book').doc(book.id).delete();
      
      // Refresh user books
      bookController.fetchUserBooks();
      
      Get.snackbar(
        "Success",
        "Book deleted successfully",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        "Error",
        "Failed to delete book: ${e.toString()}",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  Widget _buildEditTextField(String label, TextEditingController controller, {int maxLines = 1}) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        contentPadding: const EdgeInsets.all(12),
      ),
    );
  }
}
