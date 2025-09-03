import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:uuid/uuid.dart';

class SmartBookmarkController extends GetxController {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Observable variables
  final RxMap<String, List<SmartBookmark>> bookBookmarks =
      <String, List<SmartBookmark>>{}.obs;
  final RxList<BookmarkCategory> categories = <BookmarkCategory>[].obs;
  final RxBool isLoading = false.obs;
  final RxString selectedCategory = 'All'.obs;

  // Text controllers for bookmark creation
  final TextEditingController noteController = TextEditingController();
  final TextEditingController tagController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    _initializeDefaultCategories();
    loadUserBookmarks();
  }

  void _initializeDefaultCategories() {
    categories.addAll([
      BookmarkCategory(
        id: 'all',
        name: 'All',
        icon: Icons.bookmark,
        color: Colors.blue,
      ),
      BookmarkCategory(
        id: 'important',
        name: 'Important',
        icon: Icons.star,
        color: Colors.amber,
      ),
      BookmarkCategory(
        id: 'quotes',
        name: 'Quotes',
        icon: Icons.format_quote,
        color: Colors.purple,
      ),
      BookmarkCategory(
        id: 'research',
        name: 'Research',
        icon: Icons.science,
        color: Colors.green,
      ),
      BookmarkCategory(
        id: 'review',
        name: 'Review Later',
        icon: Icons.schedule,
        color: Colors.orange,
      ),
      BookmarkCategory(
        id: 'reference',
        name: 'Reference',
        icon: Icons.library_books,
        color: Colors.teal,
      ),
    ]);
  }

  // Load user's bookmarks from Firestore
  Future<void> loadUserBookmarks() async {
    try {
      isLoading(true);
      final user = _auth.currentUser;

      print('DEBUG: Loading bookmarks...');
      print('DEBUG: Current user: ${user?.uid}');

      if (user == null) {
        print('DEBUG: No authenticated user found');
        Get.snackbar(
            'Authentication Required', 'Please sign in to view bookmarks');
        return;
      }

      print('DEBUG: Fetching bookmarks from Firestore...');
      final snapshot = await _db
          .collection('UserBookmarks')
          .doc(user.uid)
          .collection('Bookmarks')
          .orderBy('createdAt', descending: true)
          .get();

      print('DEBUG: Found ${snapshot.docs.length} bookmark documents');

      bookBookmarks.clear();
      for (var doc in snapshot.docs) {
        try {
          print('DEBUG: Processing bookmark doc: ${doc.id}');
          print('DEBUG: Bookmark data: ${doc.data()}');

          final bookmark = SmartBookmark.fromJson(doc.data());
          if (bookBookmarks[bookmark.bookId] == null) {
            bookBookmarks[bookmark.bookId] = [];
          }
          bookBookmarks[bookmark.bookId]!.add(bookmark);
          print('DEBUG: Added bookmark for book: ${bookmark.bookId}');
        } catch (e) {
          print('DEBUG: Error processing bookmark doc ${doc.id}: $e');
        }
      }

      print('DEBUG: Total books with bookmarks: ${bookBookmarks.keys.length}');
      print('DEBUG: Bookmark data loaded successfully');
    } catch (e) {
      print('DEBUG: Error loading bookmarks: $e');
      Get.snackbar('Error', 'Failed to load bookmarks: ${e.toString()}');
    } finally {
      isLoading(false);
    }
  }

  // Create a new smart bookmark with AI categorization
  Future<void> createBookmark({
    required String bookId,
    required String bookTitle,
    required int pageNumber,
    required String selectedText,
    String? userNote,
    List<String>? userTags,
  }) async {
    try {
      final user = _auth.currentUser;

      print('DEBUG: Creating bookmark...');
      print('DEBUG: User: ${user?.uid}');
      print('DEBUG: BookId: $bookId');
      print('DEBUG: Selected text: $selectedText');

      if (user == null) {
        print('DEBUG: No authenticated user for bookmark creation');
        Get.snackbar(
            'Authentication Required', 'Please sign in to create bookmarks');
        return;
      }

      // AI-powered content analysis (simplified version)
      final category = _analyzeContent(selectedText, userNote);
      final autoTags = _generateTags(selectedText, userNote);

      print('DEBUG: Generated category: $category');
      print('DEBUG: Generated tags: $autoTags');

      final bookmark = SmartBookmark(
        id: const Uuid().v4(),
        bookId: bookId,
        bookTitle: bookTitle,
        pageNumber: pageNumber,
        selectedText: selectedText,
        userNote: userNote ?? '',
        category: category,
        tags: [...autoTags, ...(userTags ?? [])],
        createdAt: DateTime.now(),
        userId: user.uid,
        importance: _calculateImportance(selectedText, userNote),
      );

      print('DEBUG: Bookmark object created: ${bookmark.id}');
      print('DEBUG: Saving to Firestore...');

      // Save to Firestore
      await _db
          .collection('UserBookmarks')
          .doc(user.uid)
          .collection('Bookmarks')
          .doc(bookmark.id)
          .set(bookmark.toJson());

      print('DEBUG: Bookmark saved to Firestore successfully');

      // Update local state
      if (bookBookmarks[bookId] == null) {
        bookBookmarks[bookId] = [];
      }
      bookBookmarks[bookId]!.insert(0, bookmark);
      bookBookmarks.refresh();

      print(
          'DEBUG: Local state updated. Total bookmarks for book: ${bookBookmarks[bookId]?.length}');
      Get.snackbar('Success', 'Smart bookmark created!');
    } catch (e) {
      print('DEBUG: Error creating bookmark: $e');
      Get.snackbar('Error', 'Failed to create bookmark: ${e.toString()}');
    }
  }

  // AI-powered content analysis for categorization
  String _analyzeContent(String selectedText, String? userNote) {
    final text =
        '${selectedText.toLowerCase()} ${userNote?.toLowerCase() ?? ''}';

    // Simple keyword-based categorization (can be enhanced with ML)
    if (text.contains(RegExp(r'\b(quote|said|says|according|stated)\b'))) {
      return 'quotes';
    } else if (text
        .contains(RegExp(r'\b(important|key|crucial|significant|vital)\b'))) {
      return 'important';
    } else if (text
        .contains(RegExp(r'\b(research|study|analysis|data|findings)\b'))) {
      return 'research';
    } else if (text
        .contains(RegExp(r'\b(review|later|remember|check|revisit)\b'))) {
      return 'review';
    } else if (text
        .contains(RegExp(r'\b(definition|concept|theory|principle)\b'))) {
      return 'reference';
    }

    return 'all';
  }

  // Generate automatic tags based on content
  List<String> _generateTags(String selectedText, String? userNote) {
    final text =
        '${selectedText.toLowerCase()} ${userNote?.toLowerCase() ?? ''}';
    final tags = <String>[];

    // Extract potential tags using simple NLP techniques
    final words = text.split(RegExp(r'\W+'));
    final importantWords = words
        .where((word) =>
            word.length > 4 &&
            !_stopWords.contains(word) &&
            word.contains(RegExp(r'^[a-zA-Z]+$')))
        .toSet();

    // Add top 3 most relevant words as tags
    tags.addAll(importantWords.take(3));

    // Add contextual tags
    if (text.contains(RegExp(r'\b(chapter|section)\b')))
      tags.add('chapter-note');
    if (text.contains(RegExp(r'\b(author|writer)\b')))
      tags.add('author-insight');
    if (text.contains(RegExp(r'\b(conclusion|summary)\b'))) tags.add('summary');

    return tags;
  }

  // Calculate importance score (0.0 to 1.0)
  double _calculateImportance(String selectedText, String? userNote) {
    double score = 0.5; // Base score

    final text =
        '${selectedText.toLowerCase()} ${userNote?.toLowerCase() ?? ''}';

    // Increase score for important keywords
    if (text.contains(RegExp(r'\b(important|key|crucial|significant)\b')))
      score += 0.2;
    if (text.contains(RegExp(r'\b(remember|note|highlight)\b'))) score += 0.1;
    if (selectedText.length > 100)
      score += 0.1; // Longer selections might be more important
    if (userNote != null && userNote.isNotEmpty)
      score += 0.1; // User added note

    return score.clamp(0.0, 1.0);
  }

  // Get bookmarks for a specific book
  List<SmartBookmark> getBookmarksForBook(String bookId) {
    return bookBookmarks[bookId] ?? [];
  }

  // Get bookmarks by category
  List<SmartBookmark> getBookmarksByCategory(String categoryId) {
    if (categoryId == 'all') {
      return bookBookmarks.values.expand((list) => list).toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    }

    return bookBookmarks.values
        .expand((list) => list)
        .where((bookmark) => bookmark.category == categoryId)
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  // Search bookmarks
  List<SmartBookmark> searchBookmarks(String query) {
    final lowerQuery = query.toLowerCase();
    return bookBookmarks.values
        .expand((list) => list)
        .where((bookmark) =>
            bookmark.selectedText.toLowerCase().contains(lowerQuery) ||
            bookmark.userNote.toLowerCase().contains(lowerQuery) ||
            bookmark.tags
                .any((tag) => tag.toLowerCase().contains(lowerQuery)) ||
            bookmark.bookTitle.toLowerCase().contains(lowerQuery))
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  // Delete bookmark
  Future<void> deleteBookmark(String bookmarkId, String bookId) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;

      await _db
          .collection('UserBookmarks')
          .doc(user.uid)
          .collection('Bookmarks')
          .doc(bookmarkId)
          .delete();

      // Update local state
      bookBookmarks[bookId]
          ?.removeWhere((bookmark) => bookmark.id == bookmarkId);
      bookBookmarks.refresh();

      Get.snackbar('Success', 'Bookmark deleted');
    } catch (e) {
      Get.snackbar('Error', 'Failed to delete bookmark');
    }
  }

  // Update bookmark
  Future<void> updateBookmark(SmartBookmark bookmark) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;

      await _db
          .collection('UserBookmarks')
          .doc(user.uid)
          .collection('Bookmarks')
          .doc(bookmark.id)
          .update(bookmark.toJson());

      // Update local state
      final bookmarkList = bookBookmarks[bookmark.bookId];
      if (bookmarkList != null) {
        final index = bookmarkList.indexWhere((b) => b.id == bookmark.id);
        if (index != -1) {
          bookmarkList[index] = bookmark;
          bookBookmarks.refresh();
        }
      }

      Get.snackbar('Success', 'Bookmark updated');
    } catch (e) {
      Get.snackbar('Error', 'Failed to update bookmark');
    }
  }

  // Get bookmark statistics
  Map<String, dynamic> getBookmarkStats() {
    final allBookmarks = bookBookmarks.values.expand((list) => list).toList();
    final categoryStats = <String, int>{};

    for (var category in categories) {
      categoryStats[category.name] =
          allBookmarks.where((b) => b.category == category.id).length;
    }

    return {
      'totalBookmarks': allBookmarks.length,
      'booksWithBookmarks': bookBookmarks.keys.length,
      'categoryStats': categoryStats,
      'averageImportance': allBookmarks.isEmpty
          ? 0.0
          : allBookmarks.map((b) => b.importance).reduce((a, b) => a + b) /
              allBookmarks.length,
    };
  }

  // Common stop words to filter out from tags
  static const _stopWords = {
    'the',
    'a',
    'an',
    'and',
    'or',
    'but',
    'in',
    'on',
    'at',
    'to',
    'for',
    'of',
    'with',
    'by',
    'is',
    'are',
    'was',
    'were',
    'be',
    'been',
    'have',
    'has',
    'had',
    'do',
    'does',
    'did',
    'will',
    'would',
    'could',
    'should',
    'may',
    'might',
    'this',
    'that',
    'these',
    'those',
    'i',
    'you',
    'he',
    'she',
    'it',
    'we',
    'they'
  };
}

// Data models
class SmartBookmark {
  final String id;
  final String bookId;
  final String bookTitle;
  final int pageNumber;
  final String selectedText;
  final String userNote;
  final String category;
  final List<String> tags;
  final DateTime createdAt;
  final String userId;
  final double importance;

  SmartBookmark({
    required this.id,
    required this.bookId,
    required this.bookTitle,
    required this.pageNumber,
    required this.selectedText,
    required this.userNote,
    required this.category,
    required this.tags,
    required this.createdAt,
    required this.userId,
    required this.importance,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'bookId': bookId,
        'bookTitle': bookTitle,
        'pageNumber': pageNumber,
        'selectedText': selectedText,
        'userNote': userNote,
        'category': category,
        'tags': tags,
        'createdAt': createdAt.toIso8601String(),
        'userId': userId,
        'importance': importance,
      };

  factory SmartBookmark.fromJson(Map<String, dynamic> json) => SmartBookmark(
        id: json['id'] ?? '',
        bookId: json['bookId'] ?? '',
        bookTitle: json['bookTitle'] ?? '',
        pageNumber: json['pageNumber'] ?? 0,
        selectedText: json['selectedText'] ?? '',
        userNote: json['userNote'] ?? '',
        category: json['category'] ?? 'all',
        tags: List<String>.from(json['tags'] ?? []),
        createdAt: DateTime.parse(json['createdAt']),
        userId: json['userId'] ?? '',
        importance: (json['importance'] ?? 0.5).toDouble(),
      );

  SmartBookmark copyWith({
    String? userNote,
    String? category,
    List<String>? tags,
    double? importance,
  }) =>
      SmartBookmark(
        id: id,
        bookId: bookId,
        bookTitle: bookTitle,
        pageNumber: pageNumber,
        selectedText: selectedText,
        userNote: userNote ?? this.userNote,
        category: category ?? this.category,
        tags: tags ?? this.tags,
        createdAt: createdAt,
        userId: userId,
        importance: importance ?? this.importance,
      );
}

class BookmarkCategory {
  final String id;
  final String name;
  final IconData icon;
  final Color color;

  BookmarkCategory({
    required this.id,
    required this.name,
    required this.icon,
    required this.color,
  });
}
