import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:journal/modules/journal/controllers/journal_controller.dart';
import 'package:journal/modules/home/views/calendar_tab.dart';
import 'package:journal/modules/home/views/stats_tab.dart';
import 'package:journal/routes/app_pages.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> with SingleTickerProviderStateMixin {
  final JournalController _journalController = Get.put(JournalController());

  late TabController _tabController;
  final _tabs = ['Timeline', 'Calendar', 'Stats'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Journal'),
        actions: [IconButton(onPressed: () => Get.toNamed(Routes.settings), icon: Icon(Icons.settings))],
        bottom: TabBar(controller: _tabController, tabs: _tabs.map((tab) => Tab(text: tab)).toList()),
      ),
      body: TabBarView(controller: _tabController, children: [_buildTimelineTab(), CalendarTab(), StatsTab()]),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Get.toNamed(Routes.journalEntry),
        tooltip: 'Add Entry',
        child: Icon(Icons.add),
      ),
    );
  }

  Widget _buildTimelineTab() {
    return Obx(() {
      if (_journalController.isLoading.value) {
        return Center(child: CircularProgressIndicator());
      }

      if (_journalController.errorMessage.value.isNotEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Error', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
              Text(_journalController.errorMessage.value),
              SizedBox(height: 16),
              ElevatedButton(onPressed: _journalController.fetchAllEntries, child: Text('Retry')),
            ],
          ),
        );
      }

      if (_journalController.entries.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.book_outlined, size: 64, color: Colors.grey.shade400),
              SizedBox(height: 16),
              Text('Your journal is empty', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
              Text('Tap the + button to create your first entry'),
              SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () => Get.toNamed(Routes.journalEntry),
                icon: Icon(Icons.add),
                label: Text('New Entry'),
              ),
            ],
          ),
        );
      }

      // Group entries by date
      final groupedEntries = <String, List<dynamic>>{};

      for (final entry in _journalController.entries) {
        final date = DateFormat('MMMM d, yyyy').format(entry.createdAt);

        if (!groupedEntries.containsKey(date)) {
          groupedEntries[date] = [];
        }

        groupedEntries[date]!.add(entry);
      }

      return ListView.builder(
        padding: EdgeInsets.all(16),
        itemCount: groupedEntries.keys.length,
        itemBuilder: (context, index) {
          final date = groupedEntries.keys.elementAt(index);
          final entries = groupedEntries[date]!;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Text(date, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ),
              ...entries.map((entry) {
                return Card(
                  elevation: 2,
                  margin: EdgeInsets.only(bottom: 16),
                  child: InkWell(
                    onTap: () {
                      _journalController.selectedEntry.value = entry;
                      Get.toNamed(Routes.journalDetail);
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  entry.title,
                                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              if (entry.mood != null) Text(entry.mood!, style: TextStyle(fontSize: 24)),
                            ],
                          ),
                          SizedBox(height: 8),
                          Text(
                            entry.content,
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(fontSize: 14),
                          ),
                          SizedBox(height: 12),
                          if (entry.tags != null && entry.tags!.isNotEmpty)
                            Wrap(
                              spacing: 6,
                              children:
                                  entry.tags!.map((tag) {
                                    return Chip(
                                      label: Text(
                                        tag,
                                        style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.onPrimary),
                                      ),
                                      backgroundColor: Theme.of(context).colorScheme.primary,
                                      padding: EdgeInsets.zero,
                                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                    );
                                  }).toList(),
                            ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
            ],
          );
        },
      );
    });
  }
}
