import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/swim_record.dart';

class TrendPage extends StatelessWidget {
  const TrendPage({super.key});

  List<SwimRecord> get _mockData => [
    SwimRecord(date: DateTime.now().subtract(const Duration(days: 20)), distance: 900, duration: 1600, calories: 280, pace: 1.78, heartRate: 135, strokeCount: 28),
    SwimRecord(date: DateTime.now().subtract(const Duration(days: 15)), distance: 1100, duration: 1850, calories: 330, pace: 1.68, heartRate: 142, strokeCount: 24),
    SwimRecord(date: DateTime.now().subtract(const Duration(days: 12)), distance: 1300, duration: 2200, calories: 390, pace: 1.69, heartRate: 147, strokeCount: 23),
    SwimRecord(date: DateTime.now().subtract(const Duration(days: 8)), distance: 800, duration: 1400, calories: 240, pace: 1.75, heartRate: 140, strokeCount: 26),
    SwimRecord(date: DateTime.now().subtract(const Duration(days: 6)), distance: 1000, duration: 1800, calories: 300, pace: 1.8, heartRate: 140, strokeCount: 25),
    SwimRecord(date: DateTime.now().subtract(const Duration(days: 5)), distance: 1200, duration: 2000, calories: 350, pace: 1.67, heartRate: 145, strokeCount: 23),
    SwimRecord(date: DateTime.now().subtract(const Duration(days: 3)), distance: 1500, duration: 2400, calories: 400, pace: 1.6, heartRate: 150, strokeCount: 22),
    SwimRecord(date: DateTime.now().subtract(const Duration(days: 3)), distance: 1000, duration: 1700, calories: 320, pace: 1.7, heartRate: 142, strokeCount: 24),
    SwimRecord(date: DateTime.now().subtract(const Duration(days: 1)), distance: 1300, duration: 2100, calories: 380, pace: 1.62, heartRate: 148, strokeCount: 21),
    SwimRecord(date: DateTime.now(), distance: 1100, duration: 1900, calories: 340, pace: 1.73, heartRate: 144, strokeCount: 26),
  ];

  List<SwimRecord> get _recentData {
    // 按日期分组，对相同日期的数据求平均值
    final Map<String, List<SwimRecord>> groupedRecords = {};
    for (final record in _mockData) {
      final dateKey = '${record.date.year}-${record.date.month}-${record.date.day}';
      groupedRecords.putIfAbsent(dateKey, () => []).add(record);
    }
    
    final List<SwimRecord> averagedRecords = [];
    for (final entry in groupedRecords.entries) {
      final records = entry.value;
      final avgDistance = records.map((r) => r.distance).reduce((a, b) => a + b) / records.length;
      final avgDuration = records.map((r) => r.duration).reduce((a, b) => a + b) ~/ records.length;
      final avgCalories = records.map((r) => r.calories).reduce((a, b) => a + b) / records.length;
      final avgPace = records.map((r) => r.pace).reduce((a, b) => a + b) / records.length;
      final avgHeartRate = records.map((r) => r.heartRate).reduce((a, b) => a + b) ~/ records.length;
      final avgStrokeCount = records.map((r) => r.strokeCount).reduce((a, b) => a + b) ~/ records.length;
      
      averagedRecords.add(SwimRecord(
        date: records.first.date,
        distance: avgDistance,
        duration: avgDuration,
        calories: avgCalories,
        pace: avgPace,
        heartRate: avgHeartRate,
        strokeCount: avgStrokeCount,
      ));
    }
    
    averagedRecords.sort((a, b) => a.date.compareTo(b.date));
    return averagedRecords.take(7).toList();
  }

  String _formatDate(double value, List<SwimRecord> data) {
    final index = value.toInt();
    if (index >= 0 && index < data.length) {
      final date = data[index].date;
      return '${date.month}/${date.day}';
    }
    return '';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('游泳趋势')),
      body: _mockData.isEmpty
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.pool, size: 80, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    '目前还没有任何记录，快去游泳解锁吧',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                ],
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _buildChart('配速 (分钟/100m)', _recentData.asMap().entries.map((e) => FlSpot(e.key.toDouble(), e.value.pace)).toList(), Colors.blue, _recentData),
                  const SizedBox(height: 20),
                  _buildChart('平均心率 (bpm)', _recentData.asMap().entries.map((e) => FlSpot(e.key.toDouble(), e.value.heartRate.toDouble())).toList(), Colors.red, _recentData),
                  const SizedBox(height: 20),
                  _buildChart('划水次数/100m', _recentData.asMap().entries.map((e) => FlSpot(e.key.toDouble(), e.value.strokeCount.toDouble())).toList(), Colors.green, _recentData),
                ],
              ),
            ),
    );
  }

  Widget _buildChart(String title, List<FlSpot> spots, Color color, List<SwimRecord> data) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: LineChart(
                LineChartData(
                  gridData: const FlGridData(
                    show: true,
                    drawVerticalLine: true,
                    drawHorizontalLine: true,
                    verticalInterval: 1,
                  ),
                  titlesData: FlTitlesData(
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            _formatDate(value, data),
                            style: const TextStyle(fontSize: 10),
                          );
                        },
                        reservedSize: 30,
                        interval: 1,
                      ),
                    ),
                    leftTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: true, reservedSize: 40),
                    ),
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  borderData: FlBorderData(
                    show: true,
                    border: const Border(
                      left: BorderSide(color: Colors.grey),
                      bottom: BorderSide(color: Colors.grey),
                    ),
                  ),
                  lineBarsData: [
                    LineChartBarData(
                      spots: spots,
                      isCurved: false,
                      color: color,
                      barWidth: 3,
                      dotData: const FlDotData(show: true),
                    ),
                  ],
                  minX: 0,
                  maxX: 6,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}