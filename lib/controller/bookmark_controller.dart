import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:Readify/models/bookmodel.dart';

class BookmarkController extends GetxController {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  // Observable list of bookmarked books
  final RxList<Bookmodel> bookmarkedBooks = <Bookmodel>[].obs;
  final RxBool isLoading = false.obs;
  
  @override
  void onInit() {
    super.onInit();
    if (_auth.currentUser != null) {
      fetchBookmarks();
    }
  }

  // Check if a book is bookmarked
  bool isBookmarked(String bookId) {
    return bookmarkedBooks.any((book) => book.id == bookId);
  }

  // Add book to bookmarks
  Future<void> addBookmark(Bookmodel book) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        Get.snackbar(
          'Error',
          'Please sign in to bookmark books',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red[100],
          colorText: Colors.red[800],
          icon: const Icon(Icons.error_outline, color: Colors.red),
        );
        return;
      }

      // Add to Firestore
      await _db
          .collection('UserBookmarks')
          .doc(user.uid)
          .collection('Bookmarks')
          .doc(book.id)
          .set({
        ...book.toJson(),
        'bookmarkedAt': FieldValue.serverTimestamp(),
      });

      // Update local list
      if (!isBookmarked(book.id!)) {
        bookmarkedBooks.add(book);
      }

      Get.snackbar(
        'Success',
        'Book added to bookmarks!',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green[100],
        colorText: Colors.green[800],
        icon: const Icon(Icons.bookmark_added, color: Colors.green),
        duration: const Duration(seconds: 2),
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to bookmark: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red[100],
        colorText: Colors.red[800],
      );
    }
  }

  // Remove book from bookmarks
  Future<void> removeBookmark(String bookId) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;

      // Remove from Firestore
      await _db
          .collection('UserBookmarks')
          .doc(user.uid)
          .collection('Bookmarks')
          .doc(bookId)
          .delete();

      // Update local list
      bookmarkedBooks.removeWhere((book) => book.id == bookId);

      Get.snackbar(
        'Success',
        'Book removed from bookmarks',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange[100],
        colorText: Colors.orange[800],
        icon: const Icon(Icons.bookmark_remove, color: Colors.orange),
        duration: const Duration(seconds: 2),
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to remove bookmark: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red[100],
        colorText: Colors.red[800],
      );
    }
  }

  // Toggle bookmark status
  Future<void> toggleBookmark(Bookmodel book) async {
    if (isBookmarked(book.id!)) {
      await removeBookmark(book.id!);
    } else {
      await addBookmark(book);
    }
  }

  // Fetch all bookmarks for current user
  Future<void> fetchBookmarks() async {
    try {
      isLoading(true);
      final user = _auth.currentUser;
      if (user == null) return;

      final snapshot = await _db
          .collection('UserBookmarks')
          .doc(user.uid)
          .collection('Bookmarks')
          .orderBy('bookmarkedAt', descending: true)
          .get();

      bookmarkedBooks.clear();
      for (var doc in snapshot.docs) {
        final bookData = doc.data();
        bookData.remove('bookmarkedAt'); // Remove timestamp for model parsing
        final book = Bookmodel.fromJson(bookData);
        bookmarkedBooks.add(book);
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to load bookmarks: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red[100],
        colorText: Colors.red[800],
      );
    } finally {
      isLoading(false);
    }
  }

  // Clear all bookmarks (for sign out)
  void clearBookmarks() {
    bookmarkedBooks.clear();
  }

  // Get bookmark count
  int get bookmarkCount => bookmarkedBooks.length;
}
