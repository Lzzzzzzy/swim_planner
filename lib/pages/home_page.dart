import 'package:flutter/material.dart';
import 'trend_page.dart';
import 'records_page.dart';
import 'training_page.dart';
import 'profile_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const TrendPage(),
    const RecordsPage(),
    const TrainingPage(),
    const ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.trending_up), label: '趋势'),
          BottomNavigationBarItem(icon: Icon(Icons.history), label: '纪录'),
          BottomNavigationBarItem(icon: Icon(Icons.fitness_center), label: '训练计划'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: '个人中心'),
        ],
      ),
    );
  }
}