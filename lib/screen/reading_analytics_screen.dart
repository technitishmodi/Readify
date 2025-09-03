import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:Readify/controller/reading_progress_controller.dart';
import 'package:fl_chart/fl_chart.dart';

class ReadingAnalyticsScreen extends StatelessWidget {
  const ReadingAnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final progressController = Get.put(ReadingProgressController());
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Reading Analytics'),
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        elevation: 0,
      ),
      body: Obx(() {
        if (progressController.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        return RefreshIndicator(
          onRefresh: progressController.loadUserProgress,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildStatsOverview(progressController, colorScheme),
                const SizedBox(height: 24),
                _buildReadingChart(progressController, colorScheme),
                const SizedBox(height: 24),
                _buildStreakSection(progressController, colorScheme),
                const SizedBox(height: 24),
                _buildRecentSessions(progressController, colorScheme),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildStatsOverview(ReadingProgressController controller, ColorScheme colorScheme) {
    final stats = controller.getReadingStats();
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Reading Overview',
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
                  child: _StatCard(
                    title: 'Books Read',
                    value: '${stats['totalBooksRead']}',
                    icon: Icons.book,
                    color: Colors.green,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _StatCard(
                    title: 'Current Streak',
                    value: '${stats['currentStreak']} days',
                    icon: Icons.local_fire_department,
                    color: Colors.orange,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _StatCard(
                    title: 'Reading Speed',
                    value: '${stats['averageSpeed'].toStringAsFixed(0)} WPM',
                    icon: Icons.speed,
                    color: Colors.blue,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _StatCard(
                    title: 'This Week',
                    value: '${(stats['thisWeekMinutes'] / 60).toStringAsFixed(1)}h',
                    icon: Icons.schedule,
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

  Widget _buildReadingChart(ReadingProgressController controller, ColorScheme colorScheme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Daily Reading Time (Last 7 Days)',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: Obx(() {
                final dailyData = controller.dailyReadingMinutes;
                final last7Days = _getLast7Days();
                
                return BarChart(
                  BarChartData(
                    alignment: BarChartAlignment.spaceAround,
                    maxY: _getMaxY(dailyData, last7Days),
                    barTouchData: BarTouchData(enabled: true),
                    titlesData: FlTitlesData(
                      show: true,
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (value, meta) {
                            final index = value.toInt();
                            if (index >= 0 && index < last7Days.length) {
                              try {
                                final dateStr = last7Days[index];
                                final dateParts = dateStr.split('-');
                                if (dateParts.length == 3) {
                                  final day = int.tryParse(dateParts[2]) ?? 1;
                                  final month = int.tryParse(dateParts[1]) ?? 1;
                                  return Text(
                                    '$day/$month',
                                    style: const TextStyle(fontSize: 12),
                                  );
                                }
                              } catch (e) {
                                print('DEBUG: Error parsing date for chart: $e');
                              }
                            }
                            return const Text('');
                          },
                        ),
                      ),
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (value, meta) {
                            return Text(
                              '${value.toInt()}m',
                              style: const TextStyle(fontSize: 12),
                            );
                          },
                        ),
                      ),
                      topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    ),
                    borderData: FlBorderData(show: false),
                    barGroups: last7Days.asMap().entries.map((entry) {
                      final index = entry.key;
                      final dateKey = entry.value;
                      final minutes = dailyData[dateKey] ?? 0;
                      
                      return BarChartGroupData(
                        x: index,
                        barRods: [
                          BarChartRodData(
                            toY: minutes,
                            color: colorScheme.primary,
                            width: 20,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ],
                      );
                    }).toList(),
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStreakSection(ReadingProgressController controller, ColorScheme colorScheme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Reading Streak',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Icon(
                  Icons.local_fire_department,
                  color: Colors.orange,
                  size: 48,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Current Streak: ${controller.currentStreak.value} days',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Longest Streak: ${controller.longestStreak.value} days',
                        style: TextStyle(
                          fontSize: 14,
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 8),
                      LinearProgressIndicator(
                        value: controller.currentStreak.value / (controller.longestStreak.value + 1),
                        backgroundColor: colorScheme.surfaceContainerHighest,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.orange),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentSessions(ReadingProgressController controller, ColorScheme colorScheme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Recent Reading Sessions',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 16),
            Obx(() {
              final sessions = controller.readingSessions.take(5).toList();
              
              if (sessions.isEmpty) {
                return Center(
                  child: Text(
                    'No reading sessions yet',
                    style: TextStyle(color: colorScheme.onSurfaceVariant),
                  ),
                );
              }
              
              return ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: sessions.length,
                separatorBuilder: (_, __) => const Divider(),
                itemBuilder: (context, index) {
                  final session = sessions[index];
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: colorScheme.primaryContainer,
                      child: Icon(
                        Icons.book,
                        color: colorScheme.onPrimaryContainer,
                      ),
                    ),
                    title: Text(
                      session.bookTitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    subtitle: Text(
                      '${_formatDate(session.startTime)} • ${session.duration?.inMinutes ?? 0} min',
                    ),
                    trailing: session.pagesRead > 0
                        ? Text('${session.pagesRead} pages')
                        : null,
                  );
                },
              );
            }),
          ],
        ),
      ),
    );
  }

  List<String> _getLast7Days() {
    final now = DateTime.now();
    return List.generate(7, (index) {
      final date = now.subtract(Duration(days: 6 - index));
      return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    });
  }

  double _getMaxY(Map<String, double> dailyData, List<String> last7Days) {
    double max = 0;
    for (final dateKey in last7Days) {
      final value = dailyData[dateKey] ?? 0;
      if (value > max) max = value;
    }
    return max > 0 ? max * 1.2 : 60; // Add 20% padding or minimum 60 minutes
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date).inDays;
    
    if (difference == 0) return 'Today';
    if (difference == 1) return 'Yesterday';
    if (difference < 7) return '${difference} days ago';
    
    return '${date.day}/${date.month}/${date.year}';
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.title,
    required this.value,
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
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }
}
