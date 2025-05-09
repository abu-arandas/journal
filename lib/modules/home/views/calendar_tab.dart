import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import 'package:journal/data/models/journal_entry.dart';
import 'package:journal/modules/journal/controllers/journal_controller.dart';
import 'package:journal/routes/app_pages.dart';

class CalendarTab extends StatefulWidget {
  const CalendarTab({super.key});

  @override
  State<CalendarTab> createState() => _CalendarTabState();
}

class _CalendarTabState extends State<CalendarTab> {
  final JournalController _journalController = Get.find<JournalController>();

  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    _loadSelectedDayEntries();
  }

  void _loadSelectedDayEntries() {
    if (_selectedDay != null) {
      _journalController.fetchEntriesByDate(_selectedDay!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Calendar widget
        Card(
          margin: EdgeInsets.all(8.0),
          child: TableCalendar(
            firstDay: DateTime.utc(2020, 1, 1),
            lastDay: DateTime.utc(2030, 12, 31),
            focusedDay: _focusedDay,
            calendarFormat: _calendarFormat,
            startingDayOfWeek: StartingDayOfWeek.monday,

            // Day selection
            selectedDayPredicate: (day) {
              return isSameDay(_selectedDay, day);
            },
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
              });
              _loadSelectedDayEntries();
            },

            // Calendar format toggling
            onFormatChanged: (format) {
              setState(() {
                _calendarFormat = format;
              });
            },

            // Calendar style
            calendarStyle: CalendarStyle(
              markerDecoration: BoxDecoration(color: Theme.of(context).colorScheme.primary, shape: BoxShape.circle),
              selectedDecoration: BoxDecoration(color: Theme.of(context).colorScheme.primary, shape: BoxShape.circle),
              todayDecoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                shape: BoxShape.circle,
              ),
            ),

            // Header style
            headerStyle: HeaderStyle(
              formatButtonShowsNext: false,
              titleCentered: true,
              formatButtonDecoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20.0),
                border: Border.all(color: Theme.of(context).colorScheme.primary),
              ),
              formatButtonTextStyle: TextStyle(color: Theme.of(context).colorScheme.primary),
            ),
          ),
        ),

        // Date title
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            _selectedDay == null ? 'No date selected' : DateFormat.yMMMMd().format(_selectedDay!),
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),

        // List of entries for selected day
        Expanded(
          child: Obx(() {
            if (_journalController.isLoading.value) {
              return Center(child: CircularProgressIndicator());
            }

            if (_journalController.entries.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.calendar_today_outlined, size: 64, color: Colors.grey.shade400),
                    SizedBox(height: 16),
                    Text('No entries for this date', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    SizedBox(height: 8),
                    ElevatedButton.icon(
                      onPressed: () => Get.toNamed(Routes.journalEntry),
                      icon: Icon(Icons.add),
                      label: Text('New Entry'),
                    ),
                  ],
                ),
              );
            }

            return ListView.builder(
              padding: EdgeInsets.all(8),
              itemCount: _journalController.entries.length,
              itemBuilder: (context, index) {
                final entry = _journalController.entries[index];
                return _buildEntryCard(entry);
              },
            );
          }),
        ),
      ],
    );
  }

  Widget _buildEntryCard(JournalEntry entry) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 4),
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
                  Text(
                    DateFormat('h:mm a').format(entry.createdAt),
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
                  ),
                ],
              ),

              if (entry.mood != null) ...[SizedBox(height: 8), Text(entry.mood!, style: TextStyle(fontSize: 20))],

              SizedBox(height: 8),
              Text(entry.content, maxLines: 2, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 14)),

              if (entry.tags != null && entry.tags!.isNotEmpty) ...[
                SizedBox(height: 8),
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
            ],
          ),
        ),
      ),
    );
  }
}
