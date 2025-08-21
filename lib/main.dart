import 'package:flutter/material.dart';
import 'pages/home_page.dart';

void main() {
  runApp(const SwimPlannerApp());
}

class SwimPlannerApp extends StatelessWidget {
  const SwimPlannerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '游泳规划',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}