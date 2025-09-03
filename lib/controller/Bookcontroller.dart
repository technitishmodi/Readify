import 'dart:io';

import 'package:Readify/models/bookmodel.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

class BookController extends GetxController {
  TextEditingController title = TextEditingController();
  TextEditingController des = TextEditingController();
  TextEditingController authorname = TextEditingController();
  TextEditingController aboutauthor = TextEditingController();

  ImagePicker imagePicker = ImagePicker();

  final db = FirebaseFirestore.instance;
  final auth = FirebaseAuth.instance;

  // Observables
  RxString imageUrl = ''.obs;
  RxString pdfUrl = ''.obs;
  RxBool isImageUploading = false.obs;
  RxBool isLoading = false.obs;
  var bookData = <Bookmodel>[].obs;
  var userBooks = <Bookmodel>[].obs; // For storing user's books
  RxBool isUserBooksLoading = false.obs; // Loading state for user books
  Rx<Bookmodel?> selectedBook =
      Rx<Bookmodel?>(null); // Added for selected book functionality

//for thought posts
  final RxList<ThoughtPost> thoughtPosts = <ThoughtPost>[].obs;
  final TextEditingController thoughtController = TextEditingController();

// For eBook requests
  final RxList<BookRequest> bookRequests = <BookRequest>[].obs;
  final TextEditingController requestController = TextEditingController();

  final String bucketName = 'images';
  final String bucketName_1 = 'pdfs';

  @override
  void onInit() {
    super.onInit();
    fetchBooks();

    if (auth.currentUser != null) {
      fetchUserBooks();
    }
  }

  Future<void> refreshUserBooksAfterLogin() async {
    clearAllData();
    await fetchBooks();
    await fetchUserBooks();
  }

  @override
  void onClose() {
    clearAllData();
    super.onClose();
  }

  void clearAllData() {
    bookData.clear();
    bookData.refresh();

    userBooks.clear();
    userBooks.refresh();

    imageUrl.value = '';
    pdfUrl.value = '';
    isLoading.value = false;
    isUserBooksLoading.value = false;
  }

  // Fetch thoughts from Firestore

  // Add this to your BookController class
  Future<void> deleteBook(String bookId) async {
    try {
      isLoading(true);
      final user = auth.currentUser;
      if (user == null) throw Exception('User not logged in');

      // First verify the book belongs to current user
      final bookDoc = await db.collection("Book").doc(bookId).get();
      if (!bookDoc.exists) throw Exception('Book not found');

      final bookData = bookDoc.data();
      if (bookData?['uploaderId'] != user.uid) {
        throw Exception('You can only delete your own books');
      }

      // Delete from main collection
      await db.collection("Book").doc(bookId).delete();

      // Delete from user's personal collection
      await db
          .collection("UserBook")
          .doc(user.uid)
          .collection("Books")
          .doc(bookId)
          .delete();

      // Delete files from Supabase storage if they exist
      try {
        if (bookData?['bookUrl'] != null) {
          final pdfPath = _extractPathFromUrl(bookData!['bookUrl']);
          await Supabase.instance.client.storage
              .from(bucketName)
              .remove([pdfPath]);
        }

        if (bookData?['imageUrl'] != null) {
          final imagePath = _extractPathFromUrl(bookData!['imageUrl']);
          await Supabase.instance.client.storage
              .from(bucketName)
              .remove([imagePath]);
        }
      } catch (e) {
        print('Error deleting files from storage: $e');
      }

      // Refresh lists
      await fetchBooks();
      await fetchUserBooks();

      Get.snackbar('Success', 'Book deleted successfully');
    } catch (e) {
      Get.snackbar('Error', 'Failed to delete book: ${e.toString()}');
      rethrow;
    } finally {
      isLoading(false);
    }
  }

// Helper method to extract path from URL
  String _extractPathFromUrl(String url) {
    try {
      final uri = Uri.parse(url);
      return uri.path.split('/storage/v1/object/public/').last;
    } catch (e) {
      return url; // fallback to original if parsing fails
    }
  }

  Future<void> fetchThoughts() async {
    try {
      final snapshot = await db
          .collection("thoughts")
          .orderBy("timestamp", descending: true)
          .get();
      thoughtPosts.value =
          snapshot.docs.map((doc) => ThoughtPost.fromJson(doc.data())).toList();
    } catch (e) {
      Get.snackbar('Error', 'Failed to load thoughts');
    }
  }

// Post a new thought
  Future<void> postThought(
      String userId, String userName, String? userPhoto) async {
    try {
      if (thoughtController.text.isEmpty) return;

      final newThought = ThoughtPost(
        [], // Empty likedBy list initially
        id: Uuid().v1(),
        userId: userId,
        userName: userName,
        userPhoto: userPhoto,
        content: thoughtController.text,
        timestamp: DateTime.now(),
        likes: 0,
      );

      await db
          .collection("thoughts")
          .doc(newThought.id)
          .set(newThought.toJson());
      thoughtController.clear();
      await fetchThoughts();
    } catch (e) {
      Get.snackbar('Error', 'Failed to post thought');
    }
  }

// Add this method to your BookController class
  Future<void> deleteThought(String thoughtId) async {
    try {
      await db.collection("thoughts").doc(thoughtId).delete();
      await fetchThoughts(); // Refresh the list after deletion
      Get.snackbar('Success', 'Thought deleted successfully');
    } catch (e) {
      Get.snackbar('Error', 'Failed to delete thought: ${e.toString()}');
    }
  }

  Future<void> likeThought(String thoughtId, String userId) async {
    try {
      await db.collection("thoughts").doc(thoughtId).update({
        'likes': FieldValue.increment(1),
        'likedBy': FieldValue.arrayUnion([userId])
      });
      await fetchThoughts(); // Refresh the thoughts list
    } catch (e) {
      Get.snackbar('Error', 'Failed to like thought');
    }
  }

// Unlike a thought
  Future<void> unlikeThought(String thoughtId, String userId) async {
    try {
      await db.collection("thoughts").doc(thoughtId).update({
        'likes': FieldValue.increment(-1),
        'likedBy': FieldValue.arrayRemove([userId])
      });
      await fetchThoughts(); // Refresh the thoughts list
    } catch (e) {
      Get.snackbar('Error', 'Failed to unlike thought');
    }
  }

// Request a new book
  Future<void> requestBook(String userId, String userName) async {
    try {
      if (requestController.text.isEmpty) return;

      final newRequest = BookRequest(
        id: Uuid().v1(),
        userId: userId,
        userName: userName,
        bookTitle: requestController.text,
        timestamp: DateTime.now(),
        status: 'Pending',
      );

      await db
          .collection("bookRequests")
          .doc(newRequest.id)
          .set(newRequest.toJson());
      requestController.clear();
      Get.snackbar('Success', 'Book request submitted');
    } catch (e) {
      Get.snackbar('Error', 'Failed to submit request');
    }
  }

// Fetch book requests (for admin)
  Future<void> fetchBookRequests() async {
    try {
      final snapshot = await db
          .collection("bookRequests")
          .orderBy("timestamp", descending: true)
          .get();
      bookRequests.value =
          snapshot.docs.map((doc) => BookRequest.fromJson(doc.data())).toList();
    } catch (e) {
      Get.snackbar('Error', 'Failed to load requests');
    }
  }

  // Method to set the selected book
  void setSelectedBook(Bookmodel book) {
    selectedBook.value = book;
  }

  // Fetch books from Firestore and Supabase
  Future<void> fetchBooks() async {
    try {
      isLoading(true);
      bookData.clear();

      // Fetch only public books
      final firebaseBooks = await db
          .collection("Book")
          .where("visibility", isEqualTo: "public")
          .get();

      for (var bookDoc in firebaseBooks.docs) {
        final book = Bookmodel.fromJson(bookDoc.data());

        if (book.imageUrl != null && !book.imageUrl!.startsWith('http')) {
          book.imageUrl = await _getFullSupabaseUrl(book.imageUrl!);
        }

        if (book.bookUrl != null && !book.bookUrl!.startsWith('http')) {
          book.bookUrl = await _getFullSupabaseUrl(book.bookUrl!);
        }

        bookData.add(book);
      }

      bookData.refresh();
    } catch (e) {
      Get.snackbar('Error', 'Failed to load books: ${e.toString()}');
      print('Error fetching books: $e');
    } finally {
      isLoading(false);
    }
  }

  // Fetch user-specific books
  Future<void> fetchUserBooks() async {
    try {
      isUserBooksLoading(true);

      // Clear previous data to avoid mixing users' books
      userBooks.clear();
      userBooks.refresh();

      final user = auth.currentUser;
      if (user == null) {
        isUserBooksLoading(false);
        return;
      }

      // Fetch books uploaded by user
      final snapshot = await db
          .collection("Book")
          .where("uploaderId", isEqualTo: user.uid)
          .get();

      // Fetch books where user has access
      final privateSnapshot = await db
          .collection("Book")
          .where("allowedUsers", arrayContains: user.uid)
          .get();

      final allBooks = [...snapshot.docs, ...privateSnapshot.docs];

      for (var doc in allBooks) {
        final book = Bookmodel.fromJson(doc.data());

        if (book.imageUrl != null && !book.imageUrl!.startsWith('http')) {
          book.imageUrl = await _getFullSupabaseUrl(book.imageUrl!);
        }

        if (book.bookUrl != null && !book.bookUrl!.startsWith('http')) {
          book.bookUrl = await _getFullSupabaseUrl(book.bookUrl!);
        }

        userBooks.add(book);
      }

      userBooks.refresh();
    } catch (e) {
      Get.snackbar('Error', 'Failed to load your books: ${e.toString()}');
    } finally {
      isUserBooksLoading(false);
    }
  }

  Future<String> _getFullSupabaseUrl(String path) async {
    try {
      return Supabase.instance.client.storage
          .from(bucketName)
          .getPublicUrl(path);
    } catch (e) {
      print('Error getting URL for $path: $e');
      return path;
    }
  }

  Future<void> pickImage() async {
    try {
      isImageUploading(true);
      final XFile? image =
          await imagePicker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        await uploadImagetoSupabase(File(image.path));
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to pick image');
    } finally {
      isImageUploading(false);
    }
  }

  Future<void> uploadImagetoSupabase(File image) async {
    try {
      isImageUploading(true);
      final fileName = 'Images/${Uuid().v1()}.jpg';

      await Supabase.instance.client.storage
          .from(bucketName)
          .upload(fileName, image);

      imageUrl.value = await _getFullSupabaseUrl(fileName);
      Get.snackbar('Success', 'Image uploaded!');
    } catch (e) {
      Get.snackbar('Error', 'Image upload failed: ${e.toString()}');
    } finally {
      isImageUploading(false);
    }
  }

  Future<void> pickPDF() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
      );

      if (result != null && result.files.single.path != null) {
        await uploadPdfToSupabase(File(result.files.single.path!));
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to pick PDF');
    }
  }

  Future<void> uploadPdfToSupabase(File pdfFile) async {
    try {
      isLoading(true);
      final fileName = 'PDFs/${Uuid().v1()}.pdf';

      await Supabase.instance.client.storage
          .from(bucketName)
          .upload(fileName, pdfFile);

      pdfUrl.value = await _getFullSupabaseUrl(fileName);
      Get.snackbar('Success', 'PDF uploaded!');
    } catch (e) {
      Get.snackbar('Error', 'PDF upload failed: ${e.toString()}');
    } finally {
      isLoading(false);
    }
  }

  Future<void> createBook(
      {String visibility = 'public', String? category}) async {
    try {
      if (title.text.isEmpty || pdfUrl.isEmpty) {
        throw Exception('Title and PDF are required');
      }

      isLoading(true);
      final bookId = Uuid().v1();
      final user = auth.currentUser; // Get current user

      final newBook = Bookmodel(
        visibility: visibility,
        uploaderId: user?.uid, // Track who uploaded the book
        id: bookId,
        title: title.text,
        descriptions: des.text,
        aboutAuthor: aboutauthor.text,
        auther: authorname.text,
        bookUrl: pdfUrl.value,
        imageUrl: imageUrl.value,
        category: category, // Add category to the book
      );

      // Save to main Book collection
      await db.collection("Book").doc(bookId).set(newBook.toJson());

      // Always add to the user's private collection
      await addBookToUserDB(newBook);

      // Clear fields
      title.clear();
      des.clear();
      aboutauthor.clear();
      authorname.clear();
      imageUrl.value = '';
      pdfUrl.value = '';

      // Refresh lists
      await fetchBooks();
      await fetchUserBooks();

      Get.snackbar('Success', 'Book added successfully!');
    } catch (e) {
      Get.snackbar('Error', 'Failed to create book: ${e.toString()}');
    } finally {
      isLoading(false);
    }
  }

  Future<void> addBookToUserDB(Bookmodel book) async {
    try {
      final user = auth.currentUser;
      if (user == null) throw Exception('No user logged in');

      await db
          .collection("UserBook")
          .doc(user.uid)
          .collection("Books")
          .doc(book.id)
          .set(book.toJson(), SetOptions(merge: true));

      print('Book added to user collection successfully');
      await fetchUserBooks(); // Add this line to refresh the list
    } catch (e) {
      print('Error adding to user DB: $e');
      Get.snackbar(
          'Error', 'Failed to add book to your collection: ${e.toString()}');
      rethrow;
    }
  }

  // User-specific book management functions
  Future<void> deleteUserBook(String bookId) async {
    try {
      isLoading(true);
      final user = auth.currentUser;
      if (user == null) throw Exception('User not logged in');

      // First verify the book belongs to current user
      final bookDoc = await db.collection("Book").doc(bookId).get();
      if (!bookDoc.exists) throw Exception('Book not found');

      final bookData = bookDoc.data();
      if (bookData?['uploaderId'] != user.uid) {
        throw Exception('You can only delete your own books');
      }

      // Delete from main collection
      await db.collection("Book").doc(bookId).delete();

      // Delete from user's personal collection
      await db
          .collection("UserBook")
          .doc(user.uid)
          .collection("Books")
          .doc(bookId)
          .delete();

      // Delete files from Supabase storage if they exist
      try {
        if (bookData?['bookUrl'] != null) {
          final pdfPath = _extractPathFromUrl(bookData!['bookUrl']);
          await Supabase.instance.client.storage
              .from(bookData['bookUrl'].toString().contains('.pdf')
                  ? bucketName_1
                  : bucketName)
              .remove([pdfPath]);
        }

        if (bookData?['imageUrl'] != null) {
          final imagePath = _extractPathFromUrl(bookData!['imageUrl']);
          await Supabase.instance.client.storage
              .from(bucketName)
              .remove([imagePath]);
        }
      } catch (e) {
        print('Error deleting files from storage: $e');
      }

      // Refresh lists
      await fetchBooks();
      await fetchUserBooks();

      Get.snackbar('Success', 'Book deleted successfully');
    } catch (e) {
      Get.snackbar('Error', 'Failed to delete book: ${e.toString()}');
      rethrow;
    } finally {
      isLoading(false);
    }
  }

  // Edit user's book
  Future<void> editUserBook(
    String bookId, {
    String? newTitle,
    String? newDescription,
    String? newAuthorName,
    String? newAboutAuthor,
    String? newVisibility,
  }) async {
    try {
      isLoading(true);
      final user = auth.currentUser;
      if (user == null) throw Exception('User not logged in');

      // Verify the book belongs to current user
      final bookDoc = await db.collection("Book").doc(bookId).get();
      if (!bookDoc.exists) throw Exception('Book not found');

      final bookData = bookDoc.data();
      if (bookData?['uploaderId'] != user.uid) {
        throw Exception('You can only edit your own books');
      }

      // Prepare update data
      Map<String, dynamic> updateData = {};
      if (newTitle != null) updateData['title'] = newTitle;
      if (newDescription != null) updateData['descriptions'] = newDescription;
      if (newAuthorName != null) updateData['auther'] = newAuthorName;
      if (newAboutAuthor != null) updateData['aboutAuthor'] = newAboutAuthor;
      if (newVisibility != null) updateData['visibility'] = newVisibility;

      if (updateData.isEmpty) {
        throw Exception('No changes to update');
      }

      // Update in main collection
      await db.collection("Book").doc(bookId).update(updateData);

      // Update in user's personal collection
      await db
          .collection("UserBook")
          .doc(user.uid)
          .collection("Books")
          .doc(bookId)
          .update(updateData);

      // Refresh lists
      await fetchBooks();
      await fetchUserBooks();

      Get.snackbar('Success', 'Book updated successfully');
    } catch (e) {
      Get.snackbar('Error', 'Failed to update book: ${e.toString()}');
      rethrow;
    } finally {
      isLoading(false);
    }
  }

  // Populate edit form with existing book data
  void populateEditForm(Bookmodel book) {
    title.text = book.title ?? '';
    des.text = book.descriptions ?? '';
    authorname.text = book.auther ?? '';
    aboutauthor.text = book.aboutAuthor ?? '';
    imageUrl.value = book.imageUrl ?? '';
    pdfUrl.value = book.bookUrl ?? '';
  }

  // Clear edit form
  void clearEditForm() {
    title.clear();
    des.clear();
    authorname.clear();
    aboutauthor.clear();
    imageUrl.value = '';
    pdfUrl.value = '';
  }

  // Check if user owns the book
  bool isUserBookOwner(Bookmodel book) {
    final user = auth.currentUser;
    return user != null && book.uploaderId == user.uid;
  }
}
