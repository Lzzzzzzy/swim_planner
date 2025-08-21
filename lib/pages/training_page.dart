import 'package:flutter/material.dart';
import '../models/swim_record.dart';

class TrainingPage extends StatefulWidget {
  const TrainingPage({super.key});

  @override
  State<TrainingPage> createState() => _TrainingPageState();
}

class _TrainingPageState extends State<TrainingPage> {
  List<TrainingPlan> get _presetPlans => [
    TrainingPlan(
      name: '包干游',
      description: '持续游泳，保持稳定配速',
      sets: [TrainingSet(distance: 1000, type: '自由泳', rest: 0)],
    ),
    TrainingPlan(
      name: '金字塔游',
      description: '距离递增再递减的训练',
      sets: [
        TrainingSet(distance: 100, type: '自由泳', rest: 30),
        TrainingSet(distance: 200, type: '自由泳', rest: 60),
        TrainingSet(distance: 300, type: '自由泳', rest: 90),
        TrainingSet(distance: 200, type: '自由泳', rest: 60),
        TrainingSet(distance: 100, type: '自由泳', rest: 30),
      ],
    ),
    TrainingPlan(
      name: '冲刺游',
      description: '短距离高强度训练',
      sets: [
        TrainingSet(distance: 50, type: '冲刺', rest: 60),
        TrainingSet(distance: 50, type: '冲刺', rest: 60),
        TrainingSet(distance: 50, type: '冲刺', rest: 60),
        TrainingSet(distance: 50, type: '冲刺', rest: 60),
      ],
    ),
    TrainingPlan(
      name: '间歇游',
      description: '高强度与休息交替',
      sets: [
        TrainingSet(distance: 100, type: '快速', rest: 45),
        TrainingSet(distance: 100, type: '慢速', rest: 15),
        TrainingSet(distance: 100, type: '快速', rest: 45),
        TrainingSet(distance: 100, type: '慢速', rest: 15),
      ],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('训练计划'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _showCreatePlanDialog,
          ),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _presetPlans.length,
        itemBuilder: (context, index) {
          final plan = _presetPlans[index];
          return Card(
            child: ExpansionTile(
              leading: const Icon(Icons.fitness_center),
              title: Text(plan.name),
              subtitle: Text(plan.description),
              trailing: IconButton(
                icon: const Icon(Icons.watch),
                onPressed: () => _exportToAppleWatch(plan),
              ),
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('训练组合:', style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      ...plan.sets.map((set) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          children: [
                            Text('${set.distance}m ${set.type}'),
                            const Spacer(),
                            if (set.rest > 0) Text('休息${set.rest}秒'),
                          ],
                        ),
                      )),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showCreatePlanDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('创建训练计划'),
        content: const Text('自定义训练计划功能开发中...'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }

  void _exportToAppleWatch(TrainingPlan plan) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('正在导出"${plan.name}"到Apple Watch...')),
    );
  }
}