import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import '../models/swim_record.dart';

class RecordsPage extends StatefulWidget {
  const RecordsPage({super.key});

  @override
  State<RecordsPage> createState() => _RecordsPageState();
}

class _RecordsPageState extends State<RecordsPage> {
  DateTime _selectedDay = DateTime.now();
  DateTime _focusedDay = DateTime.now();
  bool _showCalendar = false;

  List<SwimRecord> get _mockRecords => [
    SwimRecord(date: DateTime.now(), distance: 1100, duration: 1900, calories: 340, pace: 1.73, heartRate: 144, strokeCount: 26),
    SwimRecord(date: DateTime.now().subtract(const Duration(days: 1)), distance: 1300, duration: 2100, calories: 380, pace: 1.62, heartRate: 148, strokeCount: 21),
    SwimRecord(date: DateTime.now().subtract(const Duration(days: 2)), distance: 1000, duration: 1700, calories: 320, pace: 1.7, heartRate: 142, strokeCount: 24),
  ];

  List<SwimRecord> get _filteredRecords {
    final now = DateTime.now();
    final sevenDaysAgo = now.subtract(const Duration(days: 7));
    return _mockRecords.where((record) => 
      record.date.isAfter(sevenDaysAgo) && 
      (_showCalendar ? isSameDay(record.date, _selectedDay) : true)
    ).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('游泳纪录'),
        actions: [
          IconButton(
            icon: Icon(_showCalendar ? Icons.list : Icons.calendar_today),
            onPressed: () => setState(() => _showCalendar = !_showCalendar),
          ),
        ],
      ),
      body: Column(
        children: [
          if (_showCalendar) _buildCalendar(),
          Expanded(child: _buildRecordsList()),
        ],
      ),
    );
  }

  Widget _buildCalendar() {
    return Card(
      margin: const EdgeInsets.all(16),
      child: TableCalendar<SwimRecord>(
        firstDay: DateTime.utc(2020, 1, 1),
        lastDay: DateTime.utc(2030, 12, 31),
        focusedDay: _focusedDay,
        selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
        onDaySelected: (selectedDay, focusedDay) {
          setState(() {
            _selectedDay = selectedDay;
            _focusedDay = focusedDay;
          });
        },
        eventLoader: (day) => _mockRecords.where((record) => isSameDay(record.date, day)).toList(),
      ),
    );
  }

  Widget _buildRecordsList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _filteredRecords.length,
      itemBuilder: (context, index) {
        final record = _filteredRecords[index];
        return Card(
          child: ListTile(
            leading: const Icon(Icons.pool, color: Colors.blue),
            title: Text('${record.distance.toInt()}m'),
            subtitle: Text('${_formatDuration(record.duration)} • ${record.calories.toInt()}卡路里'),
            trailing: Text('${record.date.month}/${record.date.day}'),
          ),
        );
      },
    );
  }

  String _formatDuration(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${minutes}分${remainingSeconds}秒';
  }
}