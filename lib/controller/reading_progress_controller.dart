import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ReadingProgressController extends GetxController {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  // Observable variables
  final RxMap<String, ReadingProgress> bookProgress = <String, ReadingProgress>{}.obs;
  final RxList<ReadingSession> readingSessions = <ReadingSession>[].obs;
  final RxMap<String, double> dailyReadingMinutes = <String, double>{}.obs;
  final RxInt totalBooksRead = 0.obs;
  final RxInt currentStreak = 0.obs;
  final RxInt longestStreak = 0.obs;
  final RxDouble averageReadingSpeed = 0.0.obs;
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadUserProgress();
  }

  // Load user's reading progress from Firestore
  Future<void> loadUserProgress() async {
    try {
      isLoading(true);
      final user = _auth.currentUser;
      if (user == null) return;

      // Load book progress
      final progressSnapshot = await _db
          .collection('UserProgress')
          .doc(user.uid)
          .collection('BookProgress')
          .get();

      for (var doc in progressSnapshot.docs) {
        final progress = ReadingProgress.fromJson(doc.data());
        bookProgress[doc.id] = progress;
      }

      // Load reading sessions
      final sessionsSnapshot = await _db
          .collection('UserProgress')
          .doc(user.uid)
          .collection('ReadingSessions')
          .orderBy('startTime', descending: true)
          .limit(100)
          .get();

      readingSessions.value = sessionsSnapshot.docs
          .map((doc) => ReadingSession.fromJson(doc.data()))
          .toList();

      // Calculate statistics
      await _calculateStatistics();
    } catch (e) {
      Get.snackbar('Error', 'Failed to load reading progress');
    } finally {
      isLoading(false);
    }
  }

  // Start a reading session
  Future<void> startReadingSession(String bookId, String bookTitle) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;

      final session = ReadingSession(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        bookId: bookId,
        bookTitle: bookTitle,
        startTime: DateTime.now(),
        userId: user.uid,
      );

      // Save to local storage for immediate access
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('current_session', session.toJson().toString());
      await prefs.setString('session_start_time', DateTime.now().toIso8601String());
      await prefs.setString('session_book_id', bookId);
      await prefs.setString('session_book_title', bookTitle);
    } catch (e) {
      print('Error starting reading session: $e');
    }
  }

  // End reading session and save progress
  Future<void> endReadingSession({
    required int currentPage,
    required int totalPages,
    required int wordsRead,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;

      final prefs = await SharedPreferences.getInstance();
      final sessionData = prefs.getString('current_session');
      if (sessionData == null) return;

      // Get the actual start time from stored session
      final startTimeStr = prefs.getString('session_start_time');
      final startTime = startTimeStr != null 
          ? DateTime.parse(startTimeStr)
          : DateTime.now().subtract(const Duration(minutes: 30)); // Fallback
      
      final endTime = DateTime.now();
      final duration = endTime.difference(startTime);
      
      // Only save sessions longer than 1 minute
      if (duration.inMinutes < 1) {
        await prefs.remove('current_session');
        await prefs.remove('session_start_time');
        await prefs.remove('session_book_id');
        await prefs.remove('session_book_title');
        return;
      }

      final bookId = prefs.getString('session_book_id') ?? 'unknown';
      final bookTitle = prefs.getString('session_book_title') ?? 'Unknown Book';
      
      final session = ReadingSession(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        bookId: bookId,
        bookTitle: bookTitle,
        startTime: startTime,
        endTime: endTime,
        duration: duration,
        pagesRead: currentPage,
        wordsRead: wordsRead,
        userId: user.uid,
      );

      print('DEBUG: Saving reading session - Duration: ${duration.inMinutes} minutes');

      // Save session to Firestore
      await _db
          .collection('UserProgress')
          .doc(user.uid)
          .collection('ReadingSessions')
          .doc(session.id)
          .set(session.toJson());

      // Update book progress
      await updateBookProgress(bookId, currentPage, totalPages);

      // Clear current session
      await prefs.remove('current_session');
      await prefs.remove('session_start_time');
      await prefs.remove('session_book_id');
      await prefs.remove('session_book_title');
      
      // Refresh data
      await loadUserProgress();
    } catch (e) {
      print('Error ending reading session: $e');
    }
  }

  // Update book reading progress
  Future<void> updateBookProgress(String bookId, int currentPage, int totalPages) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;

      // Ensure valid page numbers
      if (totalPages <= 0) {
        print('DEBUG: Invalid totalPages: $totalPages');
        return;
      }
      
      if (currentPage < 0) {
        currentPage = 0;
      }
      
      if (currentPage > totalPages) {
        currentPage = totalPages;
      }

      final progressPercent = totalPages > 0 
          ? (currentPage.toDouble() / totalPages.toDouble() * 100).clamp(0.0, 100.0)
          : 0.0;
      final isCompleted = progressPercent >= 100.0;

      print('DEBUG: Progress calculation - Current: $currentPage, Total: $totalPages, Percent: $progressPercent');

      final progress = ReadingProgress(
        bookId: bookId,
        currentPage: currentPage,
        totalPages: totalPages,
        progressPercent: progressPercent,
        lastReadDate: DateTime.now(),
        isCompleted: isCompleted,
        timeSpent: bookProgress[bookId]?.timeSpent ?? Duration.zero,
      );

      // Save to Firestore
      await _db
          .collection('UserProgress')
          .doc(user.uid)
          .collection('BookProgress')
          .doc(bookId)
          .set(progress.toJson(), SetOptions(merge: true));

      // Update local state
      bookProgress[bookId] = progress;
    } catch (e) {
      print('Error updating book progress: $e');
    }
  }

  // Calculate reading statistics
  Future<void> _calculateStatistics() async {
    try {
      // Calculate total books read
      totalBooksRead.value = bookProgress.values
          .where((progress) => progress.isCompleted)
          .length;

      // Calculate daily reading minutes for the last 30 days
      final now = DateTime.now();
      final thirtyDaysAgo = now.subtract(const Duration(days: 30));
      
      dailyReadingMinutes.clear();
      for (var session in readingSessions) {
        if (session.startTime.isAfter(thirtyDaysAgo)) {
          final dateKey = '${session.startTime.year}-${session.startTime.month.toString().padLeft(2, '0')}-${session.startTime.day.toString().padLeft(2, '0')}';
          final minutes = session.duration?.inMinutes.toDouble() ?? 0;
          dailyReadingMinutes[dateKey] = (dailyReadingMinutes[dateKey] ?? 0) + minutes;
        }
      }

      // Calculate reading streaks
      await _calculateReadingStreak();

      // Calculate average reading speed (words per minute)
      final totalWords = readingSessions
          .where((s) => s.wordsRead > 0 && s.duration != null)
          .fold(0, (sum, s) => sum + s.wordsRead);
      final totalMinutes = readingSessions
          .where((s) => s.duration != null)
          .fold(0.0, (sum, s) => sum + s.duration!.inMinutes);
      
      averageReadingSpeed.value = totalMinutes > 0 ? totalWords / totalMinutes : 0;
    } catch (e) {
      print('Error calculating statistics: $e');
    }
  }

  // Calculate reading streak
  Future<void> _calculateReadingStreak() async {
    final sortedDates = dailyReadingMinutes.keys.toList()..sort();
    if (sortedDates.isEmpty) return;

    int current = 0;
    int longest = 0;
    int temp = 1;

    for (int i = 1; i < sortedDates.length; i++) {
      final prevDate = DateTime.parse(sortedDates[i - 1]);
      final currDate = DateTime.parse(sortedDates[i]);
      
      if (currDate.difference(prevDate).inDays == 1) {
        temp++;
      } else {
        longest = temp > longest ? temp : longest;
        temp = 1;
      }
    }
    
    longest = temp > longest ? temp : longest;
    
    // Check if streak continues to today
    final today = DateTime.now();
    final lastReadDate = DateTime.parse(sortedDates.last);
    if (today.difference(lastReadDate).inDays <= 1) {
      current = temp;
    }

    currentStreak.value = current;
    longestStreak.value = longest;
  }

  // Get progress for a specific book
  ReadingProgress? getBookProgress(String bookId) {
    return bookProgress[bookId];
  }

  // Get reading statistics for dashboard
  Map<String, dynamic> getReadingStats() {
    return {
      'totalBooksRead': totalBooksRead.value,
      'currentStreak': currentStreak.value,
      'longestStreak': longestStreak.value,
      'averageSpeed': averageReadingSpeed.value,
      'totalSessions': readingSessions.length,
      'thisWeekMinutes': _getThisWeekMinutes(),
    };
  }

  double _getThisWeekMinutes() {
    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday - 1));
    
    return readingSessions
        .where((s) => s.startTime.isAfter(weekStart))
        .fold(0.0, (sum, s) => sum + (s.duration?.inMinutes.toDouble() ?? 0));
  }
}

// Data models
class ReadingProgress {
  final String bookId;
  final int currentPage;
  final int totalPages;
  final double progressPercent;
  final DateTime lastReadDate;
  final bool isCompleted;
  final Duration timeSpent;

  ReadingProgress({
    required this.bookId,
    required this.currentPage,
    required this.totalPages,
    required this.progressPercent,
    required this.lastReadDate,
    required this.isCompleted,
    required this.timeSpent,
  });

  Map<String, dynamic> toJson() => {
    'bookId': bookId,
    'currentPage': currentPage,
    'totalPages': totalPages,
    'progressPercent': progressPercent,
    'lastReadDate': lastReadDate.toIso8601String(),
    'isCompleted': isCompleted,
    'timeSpent': timeSpent.inMinutes,
  };

  factory ReadingProgress.fromJson(Map<String, dynamic> json) => ReadingProgress(
    bookId: json['bookId'] ?? '',
    currentPage: json['currentPage'] ?? 0,
    totalPages: json['totalPages'] ?? 0,
    progressPercent: (json['progressPercent'] ?? 0).toDouble(),
    lastReadDate: DateTime.parse(json['lastReadDate']),
    isCompleted: json['isCompleted'] ?? false,
    timeSpent: Duration(minutes: json['timeSpent'] ?? 0),
  );
}

class ReadingSession {
  final String id;
  final String bookId;
  final String bookTitle;
  final DateTime startTime;
  final DateTime? endTime;
  final Duration? duration;
  final int pagesRead;
  final int wordsRead;
  final String userId;

  ReadingSession({
    required this.id,
    required this.bookId,
    required this.bookTitle,
    required this.startTime,
    this.endTime,
    this.duration,
    this.pagesRead = 0,
    this.wordsRead = 0,
    required this.userId,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'bookId': bookId,
    'bookTitle': bookTitle,
    'startTime': startTime.toIso8601String(),
    'endTime': endTime?.toIso8601String(),
    'duration': duration?.inMinutes,
    'pagesRead': pagesRead,
    'wordsRead': wordsRead,
    'userId': userId,
  };

  factory ReadingSession.fromJson(Map<String, dynamic> json) => ReadingSession(
    id: json['id'] ?? '',
    bookId: json['bookId'] ?? '',
    bookTitle: json['bookTitle'] ?? '',
    startTime: DateTime.parse(json['startTime']),
    endTime: json['endTime'] != null ? DateTime.parse(json['endTime']) : null,
    duration: json['duration'] != null ? Duration(minutes: json['duration']) : null,
    pagesRead: json['pagesRead'] ?? 0,
    wordsRead: json['wordsRead'] ?? 0,
    userId: json['userId'] ?? '',
  );
}
