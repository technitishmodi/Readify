import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:Readify/controller/reading_goals_controller.dart';

class ReadingGoalsScreen extends StatelessWidget {
  const ReadingGoalsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final goalsController = Get.put(ReadingGoalsController());
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Reading Goals'),
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () => _showGoalSettings(context, goalsController),
            icon: const Icon(Icons.settings),
            tooltip: 'Goal Settings',
          ),
        ],
      ),
      body: Obx(() {
        if (goalsController.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        return RefreshIndicator(
          onRefresh: goalsController.loadGoals,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildProgressOverview(goalsController, colorScheme),
                const SizedBox(height: 24),
                _buildGoalsList(goalsController, colorScheme),
                const SizedBox(height: 24),
                _buildMotivationalSection(goalsController, colorScheme),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildProgressOverview(ReadingGoalsController controller, ColorScheme colorScheme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Today\'s Progress',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _ProgressCard(
                    title: 'Daily Reading',
                    progress: controller.todayProgress.value,
                    subtitle: '${controller.dailyGoalMinutes.value} min goal',
                    icon: Icons.schedule,
                    color: Colors.blue,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _ProgressCard(
                    title: 'Weekly Books',
                    progress: controller.weekProgress.value,
                    subtitle: '${controller.weeklyGoalBooks.value} book goal',
                    icon: Icons.book,
                    color: Colors.green,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _ProgressCard(
                    title: 'Monthly',
                    progress: controller.monthProgress.value,
                    subtitle: '${controller.monthlyGoalBooks.value} books',
                    icon: Icons.calendar_month,
                    color: Colors.orange,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _ProgressCard(
                    title: 'Yearly',
                    progress: controller.yearProgress.value,
                    subtitle: '${controller.yearlyGoalBooks.value} books',
                    icon: Icons.emoji_events,
                    color: Colors.purple,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGoalsList(ReadingGoalsController controller, ColorScheme colorScheme) {
    final activeGoals = controller.getActiveGoals();
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Active Goals',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 16),
            if (activeGoals.isEmpty)
              Center(
                child: Text(
                  'No active goals',
                  style: TextStyle(color: colorScheme.onSurfaceVariant),
                ),
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: activeGoals.length,
                separatorBuilder: (_, __) => const Divider(),
                itemBuilder: (context, index) {
                  final goal = activeGoals[index];
                  return _GoalTile(goal: goal, colorScheme: colorScheme);
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildMotivationalSection(ReadingGoalsController controller, ColorScheme colorScheme) {
    final completedGoals = controller.goals.where((g) => g.isCompleted).length;
    final totalGoals = controller.goals.length;
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(
              Icons.emoji_events,
              size: 48,
              color: Colors.amber,
            ),
            const SizedBox(height: 12),
            Text(
              'Keep Going!',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'You\'ve completed $completedGoals out of $totalGoals goals',
              style: TextStyle(
                color: colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            LinearProgressIndicator(
              value: totalGoals > 0 ? completedGoals / totalGoals : 0,
              backgroundColor: colorScheme.surfaceContainerHighest,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.amber),
            ),
          ],
        ),
      ),
    );
  }

  void _showGoalSettings(BuildContext context, ReadingGoalsController controller) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: _GoalSettingsSheet(controller: controller),
      ),
    );
  }
}

class _ProgressCard extends StatelessWidget {
  final String title;
  final double progress;
  final String subtitle;
  final IconData icon;
  final Color color;

  const _ProgressCard({
    required this.title,
    required this.progress,
    required this.subtitle,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              const Spacer(),
              Text(
                '${(progress * 100).toInt()}%',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: progress,
            backgroundColor: color.withOpacity(0.2),
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ],
      ),
    );
  }
}

class _GoalTile extends StatelessWidget {
  final ReadingGoal goal;
  final ColorScheme colorScheme;

  const _GoalTile({
    required this.goal,
    required this.colorScheme,
  });

  @override
  Widget build(BuildContext context) {
    final isCompleted = goal.isCompleted;
    final progressColor = isCompleted ? Colors.green : colorScheme.primary;

    return ListTile(
      leading: CircleAvatar(
        backgroundColor: progressColor.withOpacity(0.2),
        child: Icon(
          isCompleted ? Icons.check : _getGoalIcon(goal.goalType),
          color: progressColor,
        ),
      ),
      title: Text(
        goal.title,
        style: TextStyle(
          fontWeight: FontWeight.w600,
          decoration: isCompleted ? TextDecoration.lineThrough : null,
        ),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(goal.description),
          const SizedBox(height: 4),
          Text(
            '${goal.currentValue.toInt()} / ${goal.targetValue.toInt()} ${goal.unit}',
            style: TextStyle(
              color: progressColor,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          LinearProgressIndicator(
            value: goal.progressPercent,
            backgroundColor: colorScheme.surfaceContainerHighest,
            valueColor: AlwaysStoppedAnimation<Color>(progressColor),
          ),
        ],
      ),
      trailing: isCompleted
          ? Icon(Icons.emoji_events, color: Colors.amber)
          : Text(
              '${(goal.progressPercent * 100).toInt()}%',
              style: TextStyle(
                color: progressColor,
                fontWeight: FontWeight.bold,
              ),
            ),
    );
  }

  IconData _getGoalIcon(GoalType type) {
    switch (type) {
      case GoalType.daily:
        return Icons.today;
      case GoalType.weekly:
        return Icons.view_week;
      case GoalType.monthly:
        return Icons.calendar_month;
      case GoalType.yearly:
        return Icons.date_range;
    }
  }
}

class _GoalSettingsSheet extends StatelessWidget {
  final ReadingGoalsController controller;

  const _GoalSettingsSheet({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Goal Settings',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Obx(() => _GoalSlider(
            title: 'Daily Reading Goal',
            subtitle: 'Minutes per day',
            value: controller.dailyGoalMinutes.value.toDouble(),
            min: 5,
            max: 180,
            divisions: 35,
            onChanged: (value) => controller.updateDailyGoal(value.toInt()),
          )),
          const SizedBox(height: 16),
          Obx(() => _GoalSlider(
            title: 'Weekly Books Goal',
            subtitle: 'Books per week',
            value: controller.weeklyGoalBooks.value.toDouble(),
            min: 1,
            max: 5,
            divisions: 4,
            onChanged: (value) => controller.updateWeeklyGoal(value.toInt()),
          )),
          const SizedBox(height: 16),
          Obx(() => _GoalSlider(
            title: 'Monthly Books Goal',
            subtitle: 'Books per month',
            value: controller.monthlyGoalBooks.value.toDouble(),
            min: 1,
            max: 20,
            divisions: 19,
            onChanged: (value) => controller.updateMonthlyGoal(value.toInt()),
          )),
          const SizedBox(height: 16),
          Obx(() => _GoalSlider(
            title: 'Yearly Books Goal',
            subtitle: 'Books per year',
            value: controller.yearlyGoalBooks.value.toDouble(),
            min: 10,
            max: 200,
            divisions: 19,
            onChanged: (value) => controller.updateYearlyGoal(value.toInt()),
          )),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

class _GoalSlider extends StatelessWidget {
  final String title;
  final String subtitle;
  final double value;
  final double min;
  final double max;
  final int divisions;
  final ValueChanged<double> onChanged;

  const _GoalSlider({
    required this.title,
    required this.subtitle,
    required this.value,
    required this.min,
    required this.max,
    required this.divisions,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
            Text(
              value.toInt().toString(),
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
          ],
        ),
        Slider(
          value: value,
          min: min,
          max: max,
          divisions: divisions,
          onChanged: onChanged,
        ),
      ],
    );
  }
}
