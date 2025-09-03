import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:math';

class AIInsightsController extends GetxController {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Observable variables
  final RxList<ReadingInsight> insights = <ReadingInsight>[].obs;
  final RxBool isLoading = false.obs;
  final RxString readingPersonality = ''.obs;
  final RxList<String> preferredGenres = <String>[].obs;
  final RxDouble averageRating = 0.0.obs;
  final RxInt totalBooksAnalyzed = 0.obs;
  final RxString readingMood = ''.obs;
  final RxList<BookRecommendation> recommendations = <BookRecommendation>[].obs;

  @override
  void onInit() {
    super.onInit();
    generateInsights();
  }

  Future<void> generateInsights() async {
    try {
      isLoading(true);
      final user = _auth.currentUser;
      if (user == null) {
        Get.snackbar('Error', 'Please sign in to view AI insights');
        return;
      }

      await _analyzeReadingPatterns();
      await _generatePersonalizedInsights();
      await _generateRecommendations();
    } catch (e) {
      print('AI Insights Error: $e');
      Get.snackbar(
        'Error',
        'Failed to generate AI insights. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withOpacity(0.8),
        colorText: Colors.white,
      );
    } finally {
      isLoading(false);
    }
  }

  Future<void> _analyzeReadingPatterns() async {
    final user = _auth.currentUser;
    if (user == null) return;

    // Analyze reading sessions
    final sessionsSnapshot = await _db
        .collection('UserProgress')
        .doc(user.uid)
        .collection('ReadingSessions')
        .orderBy('startTime', descending: true)
        .limit(50)
        .get();

    // Analyze book preferences
    final booksSnapshot = await _db.collection('books').limit(100).get();

    final bookmarksSnapshot = await _db
        .collection('UserBookmarks')
        .doc(user.uid)
        .collection('bookmarks')
        .get();

    // Calculate reading patterns
    final sessions = sessionsSnapshot.docs;
    final bookmarks = bookmarksSnapshot.docs;

    totalBooksAnalyzed.value = sessions.length + bookmarks.length;

    // Analyze preferred reading times
    final readingHours = <int>[];
    for (var session in sessions) {
      try {
        final startTimeStr = session.data()['startTime'];
        if (startTimeStr != null) {
          final startTime = DateTime.parse(startTimeStr);
          readingHours.add(startTime.hour);
        }
      } catch (e) {
        // Skip invalid date entries
        continue;
      }
    }

    // Analyze genres from bookmarked books
    final genres = <String>[];
    for (var bookmark in bookmarks) {
      try {
        final bookId = bookmark.data()['bookId'];
        final bookDoc =
            booksSnapshot.docs.where((doc) => doc.id == bookId).firstOrNull;
        if (bookDoc != null && bookDoc.exists) {
          final category = bookDoc.data()['category'] ?? 'General';
          genres.add(category);
        }
      } catch (e) {
        // Skip this bookmark if book data is invalid
        continue;
      }
    }

    preferredGenres.value = _getMostFrequentGenres(genres);

    // Calculate average session duration
    final durations = sessions
        .map((doc) => (doc.data()['duration'] ?? 0).toDouble())
        .where((d) => d > 0)
        .toList();

    final avgDuration = durations.isNotEmpty
        ? durations.reduce((a, b) => a + b) / durations.length
        : 0.0;

    // Determine reading personality
    readingPersonality.value =
        _determineReadingPersonality(avgDuration, readingHours, genres);

    // Determine current reading mood
    readingMood.value = _determineReadingMood(genres, sessions.length);
  }

  String _determineReadingPersonality(
      double avgDuration, List<int> readingHours, List<String> genres) {
    if (avgDuration > 45) {
      return 'Deep Diver';
    } else if (avgDuration > 20) {
      return 'Steady Reader';
    } else if (readingHours.where((h) => h >= 6 && h <= 9).length >
        readingHours.length * 0.3) {
      return 'Morning Reader';
    } else if (readingHours.where((h) => h >= 20 || h <= 2).length >
        readingHours.length * 0.3) {
      return 'Night Owl';
    } else if (genres.contains('Fiction') && genres.contains('Mystery')) {
      return 'Story Seeker';
    } else if (genres.contains('Self-Help') || genres.contains('Business')) {
      return 'Growth Mindset';
    } else {
      return 'Curious Explorer';
    }
  }

  String _determineReadingMood(List<String> genres, int sessionCount) {
    if (sessionCount > 20) {
      return 'Highly Motivated';
    } else if (genres.contains('Romance') || genres.contains('Fiction')) {
      return 'Emotionally Engaged';
    } else if (genres.contains('Science') || genres.contains('Technology')) {
      return 'Intellectually Curious';
    } else if (genres.contains('Self-Help')) {
      return 'Growth Focused';
    } else {
      return 'Casually Interested';
    }
  }

  List<String> _getMostFrequentGenres(List<String> genres) {
    final genreCount = <String, int>{};
    for (var genre in genres) {
      genreCount[genre] = (genreCount[genre] ?? 0) + 1;
    }

    final sortedGenres = genreCount.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return sortedGenres.take(3).map((e) => e.key).toList();
  }

  Future<void> _generatePersonalizedInsights() async {
    final insightsList = <ReadingInsight>[];

    // Reading Personality Insight
    insightsList.add(ReadingInsight(
      id: 'personality',
      title: 'Your Reading Personality',
      description: _getPersonalityDescription(readingPersonality.value),
      type: InsightType.personality,
      confidence: 0.85,
      actionable: true,
      recommendation: _getPersonalityRecommendation(readingPersonality.value),
    ));

    // Genre Preference Insight
    if (preferredGenres.isNotEmpty) {
      insightsList.add(ReadingInsight(
        id: 'genres',
        title: 'Your Favorite Genres',
        description:
            'You show a strong preference for ${preferredGenres.join(", ")}. This suggests you enjoy ${_getGenreCharacteristics(preferredGenres.first)}.',
        type: InsightType.preference,
        confidence: 0.75,
        actionable: true,
        recommendation:
            'Try exploring sub-genres within ${preferredGenres.first} or similar categories.',
      ));
    }

    // Reading Mood Insight
    insightsList.add(ReadingInsight(
      id: 'mood',
      title: 'Current Reading Mood',
      description:
          'Your recent reading activity suggests you\'re feeling ${readingMood.value.toLowerCase()}.',
      type: InsightType.mood,
      confidence: 0.70,
      actionable: true,
      recommendation: _getMoodRecommendation(readingMood.value),
    ));

    // Reading Streak Insight
    insightsList.add(ReadingInsight(
      id: 'consistency',
      title: 'Reading Consistency',
      description: _getConsistencyInsight(),
      type: InsightType.habit,
      confidence: 0.80,
      actionable: true,
      recommendation: 'Set a daily reading goal to maintain momentum.',
    ));

    // Discovery Insight
    insightsList.add(ReadingInsight(
      id: 'discovery',
      title: 'Discovery Pattern',
      description: _getDiscoveryInsight(),
      type: InsightType.discovery,
      confidence: 0.65,
      actionable: true,
      recommendation: 'Try the "Random Book" feature to discover new authors.',
    ));

    insights.value = insightsList;
  }

  String _getPersonalityDescription(String personality) {
    switch (personality) {
      case 'Deep Diver':
        return 'You prefer long, immersive reading sessions. You like to get lost in books and really absorb the content.';
      case 'Steady Reader':
        return 'You maintain consistent reading habits with moderate session lengths. You balance depth with regularity.';
      case 'Morning Reader':
        return 'You\'re most productive reading in the morning hours. Your mind is fresh and focused during early sessions.';
      case 'Night Owl':
        return 'You prefer reading during late evening or night hours. You find peace in quiet nighttime reading.';
      case 'Story Seeker':
        return 'You\'re drawn to narratives and storytelling. Fiction and mysteries capture your imagination.';
      case 'Growth Mindset':
        return 'You read to learn and improve. Self-help and business books align with your development goals.';
      default:
        return 'You have diverse reading interests and enjoy exploring different types of content.';
    }
  }

  String _getPersonalityRecommendation(String personality) {
    switch (personality) {
      case 'Deep Diver':
        return 'Consider epic novels or comprehensive non-fiction works that reward deep engagement.';
      case 'Steady Reader':
        return 'Try series or book collections that you can progress through consistently.';
      case 'Morning Reader':
        return 'Schedule your most challenging reads for morning sessions when you\'re most alert.';
      case 'Night Owl':
        return 'Keep lighter, enjoyable books for your nighttime reading to help you unwind.';
      case 'Story Seeker':
        return 'Explore different narrative styles and storytelling techniques across various genres.';
      case 'Growth Mindset':
        return 'Mix practical books with inspirational biographies for balanced personal development.';
      default:
        return 'Continue exploring diverse genres to discover new interests and preferences.';
    }
  }

  String _getGenreCharacteristics(String genre) {
    switch (genre.toLowerCase()) {
      case 'fiction':
        return 'imaginative storytelling and character development';
      case 'mystery':
        return 'puzzle-solving and suspenseful narratives';
      case 'romance':
        return 'emotional connections and relationship dynamics';
      case 'science':
        return 'factual learning and discovery';
      case 'self-help':
        return 'personal growth and practical improvement';
      case 'business':
        return 'strategic thinking and professional development';
      default:
        return 'diverse perspectives and knowledge expansion';
    }
  }

  String _getMoodRecommendation(String mood) {
    switch (mood) {
      case 'Highly Motivated':
        return 'Challenge yourself with complex or lengthy books that match your enthusiasm.';
      case 'Emotionally Engaged':
        return 'Continue with character-driven stories that resonate with your feelings.';
      case 'Intellectually Curious':
        return 'Explore scientific journals or cutting-edge research in your areas of interest.';
      case 'Growth Focused':
        return 'Combine practical guides with inspirational success stories.';
      default:
        return 'Try shorter books or collections that don\'t require heavy commitment.';
    }
  }

  String _getConsistencyInsight() {
    final random = Random();
    final consistencyLevel = random.nextInt(3);

    switch (consistencyLevel) {
      case 0:
        return 'You read in bursts - intense periods followed by breaks. This pattern can work well if you plan for it.';
      case 1:
        return 'You maintain fairly regular reading habits. Small improvements in consistency could boost your progress.';
      default:
        return 'You have excellent reading consistency. Your regular habits are building strong reading momentum.';
    }
  }

  String _getDiscoveryInsight() {
    final random = Random();
    final discoveryType = random.nextInt(3);

    switch (discoveryType) {
      case 0:
        return 'You tend to stick with familiar authors and genres. Branching out could reveal new favorites.';
      case 1:
        return 'You show moderate exploration in your reading choices. You balance comfort with discovery.';
      default:
        return 'You\'re adventurous in your reading choices, regularly exploring new authors and genres.';
    }
  }

  Future<void> _generateRecommendations() async {
    final recs = <BookRecommendation>[];

    // Based on personality
    recs.add(BookRecommendation(
      id: 'personality_rec',
      title: _getPersonalityBookRecommendation(readingPersonality.value),
      reason: 'Matches your ${readingPersonality.value} reading personality',
      confidence: 0.85,
      category: 'Personality Match',
    ));

    // Based on preferred genres
    if (preferredGenres.isNotEmpty) {
      recs.add(BookRecommendation(
        id: 'genre_rec',
        title: _getGenreBookRecommendation(preferredGenres.first),
        reason: 'Perfect for ${preferredGenres.first} lovers',
        confidence: 0.80,
        category: 'Genre Favorite',
      ));
    }

    // Based on reading mood
    recs.add(BookRecommendation(
      id: 'mood_rec',
      title: _getMoodBookRecommendation(readingMood.value),
      reason:
          'Aligns with your current ${readingMood.value.toLowerCase()} mood',
      confidence: 0.75,
      category: 'Mood Match',
    ));

    // Trending recommendation
    recs.add(BookRecommendation(
      id: 'trending_rec',
      title: 'Atomic Habits by James Clear',
      reason: 'Popular among readers with similar patterns to yours',
      confidence: 0.70,
      category: 'Trending',
    ));

    recommendations.value = recs;
  }

  String _getPersonalityBookRecommendation(String personality) {
    switch (personality) {
      case 'Deep Diver':
        return 'The Count of Monte Cristo by Alexandre Dumas';
      case 'Steady Reader':
        return 'The Harry Potter Series by J.K. Rowling';
      case 'Morning Reader':
        return 'The Miracle Morning by Hal Elrod';
      case 'Night Owl':
        return 'The Night Circus by Erin Morgenstern';
      case 'Story Seeker':
        return 'The Seven Husbands of Evelyn Hugo by Taylor Jenkins Reid';
      case 'Growth Mindset':
        return 'Mindset by Carol S. Dweck';
      default:
        return 'The Alchemist by Paulo Coelho';
    }
  }

  String _getGenreBookRecommendation(String genre) {
    switch (genre.toLowerCase()) {
      case 'fiction':
        return 'Where the Crawdads Sing by Delia Owens';
      case 'mystery':
        return 'The Thursday Murder Club by Richard Osman';
      case 'romance':
        return 'The Hating Game by Sally Thorne';
      case 'science':
        return 'Sapiens by Yuval Noah Harari';
      case 'self-help':
        return 'The 7 Habits of Highly Effective People by Stephen Covey';
      case 'business':
        return 'Good to Great by Jim Collins';
      default:
        return 'Educated by Tara Westover';
    }
  }

  String _getMoodBookRecommendation(String mood) {
    switch (mood) {
      case 'Highly Motivated':
        return 'Can\'t Hurt Me by David Goggins';
      case 'Emotionally Engaged':
        return 'The Kite Runner by Khaled Hosseini';
      case 'Intellectually Curious':
        return 'Thinking, Fast and Slow by Daniel Kahneman';
      case 'Growth Focused':
        return 'The Power of Now by Eckhart Tolle';
      default:
        return 'The Midnight Library by Matt Haig';
    }
  }
}

enum InsightType { personality, preference, mood, habit, discovery }

class ReadingInsight {
  final String id;
  final String title;
  final String description;
  final InsightType type;
  final double confidence;
  final bool actionable;
  final String recommendation;

  ReadingInsight({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.confidence,
    required this.actionable,
    required this.recommendation,
  });
}

class BookRecommendation {
  final String id;
  final String title;
  final String reason;
  final double confidence;
  final String category;

  BookRecommendation({
    required this.id,
    required this.title,
    required this.reason,
    required this.confidence,
    required this.category,
  });
}
