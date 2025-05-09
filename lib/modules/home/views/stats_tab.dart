import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:journal/data/models/journal_entry.dart';
import 'package:journal/modules/journal/controllers/journal_controller.dart';
import 'package:intl/intl.dart';

class StatsTab extends StatefulWidget {
  const StatsTab({super.key});

  @override
  State<StatsTab> createState() => _StatsTabState();
}

class _StatsTabState extends State<StatsTab> {
  final JournalController _journalController = Get.find<JournalController>();

  @override
  void initState() {
    super.initState();
    _journalController.fetchAllEntries();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (_journalController.isLoading.value) {
        return Center(child: CircularProgressIndicator());
      }

      if (_journalController.entries.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.bar_chart, size: 64, color: Colors.grey.shade400),
              SizedBox(height: 16),
              Text('No data to analyze', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
              Text('Add some journal entries to see statistics', textAlign: TextAlign.center),
            ],
          ),
        );
      }

      // Analyze the entries
      final stats = _analyzeEntries(_journalController.entries);

      return SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSummaryCard(stats),
            SizedBox(height: 24),
            _buildMoodDistributionChart(stats),
            SizedBox(height: 24),
            _buildEntriesOverTimeChart(stats),
            SizedBox(height: 24),
            _buildPopularTagsChart(stats),
          ],
        ),
      );
    });
  }

  Widget _buildSummaryCard(Map<String, dynamic> stats) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Journal Summary', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            SizedBox(height: 16),
            _buildStatItem(icon: Icons.book, label: 'Total Entries', value: stats['totalEntries'].toString()),
            _buildStatItem(icon: Icons.calendar_today, label: 'Current Streak', value: '${stats['streak']} days'),
            _buildStatItem(
              icon: Icons.emoji_emotions,
              label: 'Most Common Mood',
              value: stats['mostCommonMood'] ?? 'No data',
            ),
            _buildStatItem(
              icon: Icons.text_fields,
              label: 'Average Words per Entry',
              value: stats['avgWords'].toStringAsFixed(1),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem({required IconData icon, required String label, required String value}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, color: Theme.of(context).colorScheme.primary),
          SizedBox(width: 12),
          Expanded(child: Text(label, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500))),
          Text(value, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildMoodDistributionChart(Map<String, dynamic> stats) {
    final moodData = stats['moodDistribution'] as Map<String, int>;

    if (moodData.isEmpty) {
      return SizedBox.shrink();
    }

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Mood Distribution', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            SizedBox(height: 16),
            SizedBox(
              height: 200,
              child:
                  moodData.isEmpty
                      ? Center(child: Text('No mood data available'))
                      : PieChart(
                        PieChartData(sections: _createPieSections(moodData), centerSpaceRadius: 40, sectionsSpace: 2),
                      ),
            ),
            SizedBox(height: 16),
            Wrap(
              spacing: 16,
              runSpacing: 8,
              children:
                  moodData.entries.map((entry) {
                    final index = moodData.keys.toList().indexOf(entry.key);
                    return Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(shape: BoxShape.circle, color: _getMoodColor(index)),
                        ),
                        SizedBox(width: 4),
                        Text('${entry.key} (${entry.value})'),
                      ],
                    );
                  }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEntriesOverTimeChart(Map<String, dynamic> stats) {
    final timeData = stats['entriesOverTime'] as Map<String, int>;

    if (timeData.isEmpty) {
      return SizedBox.shrink();
    }

    final spots =
        timeData.entries.map((entry) {
          final date = DateFormat('MM/dd').parse(entry.key);
          return FlSpot(date.day.toDouble(), entry.value.toDouble());
        }).toList();

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Entries Over Time', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            SizedBox(height: 16),
            SizedBox(
              height: 200,
              child:
                  spots.isEmpty
                      ? Center(child: Text('Not enough data'))
                      : LineChart(
                        LineChartData(
                          gridData: FlGridData(show: false),
                          titlesData: FlTitlesData(
                            leftTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                getTitlesWidget: (value, meta) {
                                  return Text(
                                    value.toInt().toString(),
                                    style: TextStyle(color: Colors.grey, fontSize: 12),
                                  );
                                },
                                reservedSize: 30,
                              ),
                            ),
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                getTitlesWidget: (value, meta) {
                                  return Text(
                                    value.toInt().toString(),
                                    style: TextStyle(color: Colors.grey, fontSize: 12),
                                  );
                                },
                                reservedSize: 30,
                              ),
                            ),
                            rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                            topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          ),
                          borderData: FlBorderData(show: true),
                          lineBarsData: [
                            LineChartBarData(
                              spots: spots,
                              isCurved: true,
                              color: Theme.of(context).colorScheme.primary,
                              barWidth: 3,
                              isStrokeCapRound: true,
                              dotData: FlDotData(show: true),
                              belowBarData: BarAreaData(
                                show: true,
                                color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
                              ),
                            ),
                          ],
                        ),
                      ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPopularTagsChart(Map<String, dynamic> stats) {
    final tagsData = stats['popularTags'] as Map<String, int>;

    if (tagsData.isEmpty) {
      return SizedBox.shrink();
    }

    final sortedTags = tagsData.entries.toList()..sort((a, b) => b.value.compareTo(a.value));

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Popular Tags', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            SizedBox(height: 16),
            ...sortedTags
                .take(5)
                .map(
                  (tag) => Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: LinearProgressIndicator(
                      value: tag.value / (sortedTags.first.value),
                      backgroundColor: Colors.grey.shade200,
                      valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).colorScheme.primary),
                      minHeight: 20,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
            SizedBox(height: 8),
            ...sortedTags
                .take(5)
                .map(
                  (tag) => Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [Text(tag.key), Text('${tag.value} entries')],
                    ),
                  ),
                ),
          ],
        ),
      ),
    );
  }

  List<PieChartSectionData> _createPieSections(Map<String, int> moodData) {
    return moodData.entries.map((entry) {
      final index = moodData.keys.toList().indexOf(entry.key);
      return PieChartSectionData(
        value: entry.value.toDouble(),
        title: entry.key,
        radius: 80,
        titleStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
        color: _getMoodColor(index),
      );
    }).toList();
  }

  Color _getMoodColor(int index) {
    final colors = [
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.red,
      Colors.purple,
      Colors.teal,
      Colors.amber,
      Colors.indigo,
    ];

    return colors[index % colors.length];
  }

  Map<String, dynamic> _analyzeEntries(List<JournalEntry> entries) {
    final Map<String, dynamic> result = {};

    // Total entries
    result['totalEntries'] = entries.length;

    // Calculate streak (simplified for demo purposes)
    result['streak'] = 1;

    // Average words per entry
    final totalWords = entries.fold<int>(0, (sum, entry) => sum + entry.content.split(' ').length);
    result['avgWords'] = entries.isEmpty ? 0.0 : totalWords / entries.length;

    // Mood distribution
    final Map<String, int> moodCounts = {};
    for (final entry in entries) {
      if (entry.mood != null) {
        moodCounts[entry.mood!] = (moodCounts[entry.mood!] ?? 0) + 1;
      }
    }
    result['moodDistribution'] = moodCounts;

    // Most common mood
    String? mostCommonMood;
    int maxCount = 0;
    moodCounts.forEach((mood, count) {
      if (count > maxCount) {
        maxCount = count;
        mostCommonMood = mood;
      }
    });
    result['mostCommonMood'] = mostCommonMood;

    // Entries over time (last 7 days)
    final Map<String, int> entriesOverTime = {};
    final now = DateTime.now();
    for (int i = 0; i < 7; i++) {
      final date = now.subtract(Duration(days: i));
      final dateKey = DateFormat('MM/dd').format(date);
      entriesOverTime[dateKey] = 0;
    }

    for (final entry in entries) {
      final diff = now.difference(entry.createdAt).inDays;
      if (diff < 7) {
        final dateKey = DateFormat('MM/dd').format(entry.createdAt);
        entriesOverTime[dateKey] = (entriesOverTime[dateKey] ?? 0) + 1;
      }
    }
    result['entriesOverTime'] = entriesOverTime;

    // Popular tags
    final Map<String, int> tagCounts = {};
    for (final entry in entries) {
      if (entry.tags != null) {
        for (final tag in entry.tags!) {
          tagCounts[tag] = (tagCounts[tag] ?? 0) + 1;
        }
      }
    }
    result['popularTags'] = tagCounts;

    return result;
  }
}
