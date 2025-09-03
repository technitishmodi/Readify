import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ReadingGoalsController extends GetxController {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Observable variables
  final RxList<ReadingGoal> goals = <ReadingGoal>[].obs;
  final RxBool isLoading = false.obs;
  final RxInt dailyGoalMinutes = 30.obs;
  final RxInt weeklyGoalBooks = 1.obs;
  final RxInt monthlyGoalBooks = 4.obs;
  final RxInt yearlyGoalBooks = 50.obs;
  final RxDouble todayProgress = 0.0.obs;
  final RxDouble weekProgress = 0.0.obs;
  final RxDouble monthProgress = 0.0.obs;
  final RxDouble yearProgress = 0.0.obs;

  @override
  void onInit() {
    super.onInit();
    loadGoals();
  }

  Future<void> loadGoals() async {
    try {
      isLoading(true);
      final user = _auth.currentUser;
      if (user == null) return;

      // Load goals from Firestore
      final goalsSnapshot = await _db
          .collection('UserGoals')
          .doc(user.uid)
          .collection('Goals')
          .get();

      if (goalsSnapshot.docs.isNotEmpty) {
        goals.value = goalsSnapshot.docs
            .map((doc) => ReadingGoal.fromJson(doc.data()))
            .toList();
      } else {
        // Create default goals
        await _createDefaultGoals();
      }

      // Load preferences
      final prefs = await SharedPreferences.getInstance();
      dailyGoalMinutes.value = prefs.getInt('daily_goal_minutes') ?? 30;
      weeklyGoalBooks.value = prefs.getInt('weekly_goal_books') ?? 1;
      monthlyGoalBooks.value = prefs.getInt('monthly_goal_books') ?? 4;
      yearlyGoalBooks.value = prefs.getInt('yearly_goal_books') ?? 50;

      // Calculate progress
      await _calculateProgress();
    } catch (e) {
      Get.snackbar('Error', 'Failed to load reading goals');
    } finally {
      isLoading(false);
    }
  }

  Future<void> _createDefaultGoals() async {
    final user = _auth.currentUser;
    if (user == null) return;

    final defaultGoals = [
      ReadingGoal(
        id: 'daily_reading',
        title: 'Daily Reading',
        description: 'Read for 30 minutes every day',
        targetValue: 30,
        currentValue: 0,
        goalType: GoalType.daily,
        unit: 'minutes',
        isActive: true,
        createdAt: DateTime.now(),
      ),
      ReadingGoal(
        id: 'weekly_books',
        title: 'Weekly Books',
        description: 'Complete 1 book per week',
        targetValue: 1,
        currentValue: 0,
        goalType: GoalType.weekly,
        unit: 'books',
        isActive: true,
        createdAt: DateTime.now(),
      ),
      ReadingGoal(
        id: 'monthly_books',
        title: 'Monthly Books',
        description: 'Read 4 books per month',
        targetValue: 4,
        currentValue: 0,
        goalType: GoalType.monthly,
        unit: 'books',
        isActive: true,
        createdAt: DateTime.now(),
      ),
      ReadingGoal(
        id: 'yearly_books',
        title: 'Yearly Challenge',
        description: 'Complete 50 books this year',
        targetValue: 50,
        currentValue: 0,
        goalType: GoalType.yearly,
        unit: 'books',
        isActive: true,
        createdAt: DateTime.now(),
      ),
    ];

    for (var goal in defaultGoals) {
      await _db
          .collection('UserGoals')
          .doc(user.uid)
          .collection('Goals')
          .doc(goal.id)
          .set(goal.toJson());
    }

    goals.value = defaultGoals;
  }

  Future<void> updateGoal(
    String goalId, {
    double? targetValue,
    double? currentValue,
    bool? isActive,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;

      final goalIndex = goals.indexWhere((g) => g.id == goalId);
      if (goalIndex == -1) return;

      final updatedGoal = goals[goalIndex].copyWith(
        targetValue: targetValue ?? goals[goalIndex].targetValue,
        currentValue: currentValue ?? goals[goalIndex].currentValue,
        isActive: isActive ?? goals[goalIndex].isActive,
      );

      await _db
          .collection('UserGoals')
          .doc(user.uid)
          .collection('Goals')
          .doc(goalId)
          .update(updatedGoal.toJson());

      goals[goalIndex] = updatedGoal;
      await _calculateProgress();
    } catch (e) {
      Get.snackbar('Error', 'Failed to update goal');
    }
  }

  Future<void> updateDailyGoal(int minutes) async {
    dailyGoalMinutes.value = minutes;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('daily_goal_minutes', minutes);
    await updateGoal('daily_reading', targetValue: minutes.toDouble());
  }

  Future<void> updateWeeklyGoal(int books) async {
    weeklyGoalBooks.value = books;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('weekly_goal_books', books);
    await updateGoal('weekly_books', targetValue: books.toDouble());
  }

  Future<void> updateMonthlyGoal(int books) async {
    monthlyGoalBooks.value = books;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('monthly_goal_books', books);
    await updateGoal('monthly_books', targetValue: books.toDouble());
  }

  Future<void> updateYearlyGoal(int books) async {
    yearlyGoalBooks.value = books;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('yearly_goal_books', books);
    await updateGoal('yearly_books', targetValue: books.toDouble());
  }

  Future<void> _calculateProgress() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;

      final now = DateTime.now();

      // Calculate today's reading time
      final todayStart = DateTime(now.year, now.month, now.day);
      final todayEnd = todayStart.add(const Duration(days: 1));

      final todaySessions = await _db
          .collection('UserProgress')
          .doc(user.uid)
          .collection('ReadingSessions')
          .where('startTime',
              isGreaterThanOrEqualTo: todayStart.toIso8601String())
          .where('startTime', isLessThan: todayEnd.toIso8601String())
          .get();

      double todayMinutes = 0;
      for (var doc in todaySessions.docs) {
        final duration = doc.data()['duration'] ?? 0;
        todayMinutes += duration.toDouble();
      }

      todayProgress.value =
          (todayMinutes / dailyGoalMinutes.value).clamp(0.0, 1.0);

      // Calculate weekly progress
      final weekStart = now.subtract(Duration(days: now.weekday - 1));
      final weekEnd = weekStart.add(const Duration(days: 7));

      final weeklyBooks = await _db
          .collection('UserProgress')
          .doc(user.uid)
          .collection('BookProgress')
          .where('lastReadDate',
              isGreaterThanOrEqualTo: weekStart.toIso8601String())
          .where('lastReadDate', isLessThan: weekEnd.toIso8601String())
          .where('isCompleted', isEqualTo: true)
          .get();

      weekProgress.value =
          (weeklyBooks.docs.length / weeklyGoalBooks.value).clamp(0.0, 1.0);

      // Calculate monthly progress
      final monthStart = DateTime(now.year, now.month, 1);
      final monthEnd = DateTime(now.year, now.month + 1, 1);

      final monthlyBooks = await _db
          .collection('UserProgress')
          .doc(user.uid)
          .collection('BookProgress')
          .where('lastReadDate',
              isGreaterThanOrEqualTo: monthStart.toIso8601String())
          .where('lastReadDate', isLessThan: monthEnd.toIso8601String())
          .where('isCompleted', isEqualTo: true)
          .get();

      monthProgress.value =
          (monthlyBooks.docs.length / monthlyGoalBooks.value).clamp(0.0, 1.0);

      // Calculate yearly progress
      final yearStart = DateTime(now.year, 1, 1);
      final yearEnd = DateTime(now.year + 1, 1, 1);

      final yearlyBooks = await _db
          .collection('UserProgress')
          .doc(user.uid)
          .collection('BookProgress')
          .where('lastReadDate',
              isGreaterThanOrEqualTo: yearStart.toIso8601String())
          .where('lastReadDate', isLessThan: yearEnd.toIso8601String())
          .where('isCompleted', isEqualTo: true)
          .get();

      yearProgress.value =
          (yearlyBooks.docs.length / yearlyGoalBooks.value).clamp(0.0, 1.0);

      // Update goal current values
      await updateGoal('daily_reading', currentValue: todayMinutes);
      await updateGoal('weekly_books',
          currentValue: weeklyBooks.docs.length.toDouble());
      await updateGoal('monthly_books',
          currentValue: monthlyBooks.docs.length.toDouble());
      await updateGoal('yearly_books',
          currentValue: yearlyBooks.docs.length.toDouble());
    } catch (e) {
      print('Error calculating progress: $e');
    }
  }

  List<ReadingGoal> getActiveGoals() {
    return goals.where((goal) => goal.isActive).toList();
  }

  ReadingGoal? getGoalById(String id) {
    try {
      return goals.firstWhere((goal) => goal.id == id);
    } catch (e) {
      return null;
    }
  }
}

enum GoalType { daily, weekly, monthly, yearly }

class ReadingGoal {
  final String id;
  final String title;
  final String description;
  final double targetValue;
  final double currentValue;
  final GoalType goalType;
  final String unit;
  final bool isActive;
  final DateTime createdAt;
  final DateTime? completedAt;

  ReadingGoal({
    required this.id,
    required this.title,
    required this.description,
    required this.targetValue,
    required this.currentValue,
    required this.goalType,
    required this.unit,
    required this.isActive,
    required this.createdAt,
    this.completedAt,
  });

  ReadingGoal copyWith({
    String? id,
    String? title,
    String? description,
    double? targetValue,
    double? currentValue,
    GoalType? goalType,
    String? unit,
    bool? isActive,
    DateTime? createdAt,
    DateTime? completedAt,
  }) {
    return ReadingGoal(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      targetValue: targetValue ?? this.targetValue,
      currentValue: currentValue ?? this.currentValue,
      goalType: goalType ?? this.goalType,
      unit: unit ?? this.unit,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      completedAt: completedAt ?? this.completedAt,
    );
  }

  double get progressPercent =>
      targetValue > 0 ? (currentValue / targetValue).clamp(0.0, 1.0) : 0.0;
  bool get isCompleted => currentValue >= targetValue;

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'description': description,
        'targetValue': targetValue,
        'currentValue': currentValue,
        'goalType': goalType.toString(),
        'unit': unit,
        'isActive': isActive,
        'createdAt': createdAt.toIso8601String(),
        'completedAt': completedAt?.toIso8601String(),
      };

  factory ReadingGoal.fromJson(Map<String, dynamic> json) => ReadingGoal(
        id: json['id'] ?? '',
        title: json['title'] ?? '',
        description: json['description'] ?? '',
        targetValue: (json['targetValue'] ?? 0).toDouble(),
        currentValue: (json['currentValue'] ?? 0).toDouble(),
        goalType: GoalType.values.firstWhere(
          (e) => e.toString() == json['goalType'],
          orElse: () => GoalType.daily,
        ),
        unit: json['unit'] ?? '',
        isActive: json['isActive'] ?? true,
        createdAt: DateTime.parse(json['createdAt']),
        completedAt: json['completedAt'] != null
            ? DateTime.parse(json['completedAt'])
            : null,
      );
}
