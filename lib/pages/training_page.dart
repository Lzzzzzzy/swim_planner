import 'package:flutter/material.dart';
import 'package:health/health.dart';
import '../models/swim_record.dart';
import 'create_plan_page.dart';

class TrainingPage extends StatefulWidget {
  const TrainingPage({super.key});

  @override
  State<TrainingPage> createState() => _TrainingPageState();
}

class _TrainingPageState extends State<TrainingPage> {
  List<TrainingPlan> _userPlans = [];

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
            onPressed: _navigateToCreatePlan,
          ),
        ],
      ),
      body: _userPlans.isEmpty
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.fitness_center, size: 80, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    '还没有训练计划，点击上方+号新增',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                ],
              ),
            )
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                const Text('我的计划', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                ..._userPlans.map((plan) => _buildPlanCard(plan, false)),
              ],
            ),
    );
  }

  Widget _buildPlanCard(TrainingPlan plan, bool isPreset) {
    return Card(
      child: ExpansionTile(
        leading: const Icon(Icons.fitness_center),
        title: Text(plan.name),
        subtitle: Text(plan.description),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isPreset)
              IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () => _editPlan(plan),
              ),
            if (!isPreset)
              IconButton(
                icon: const Icon(Icons.delete),
                onPressed: () => _deletePlan(plan),
              ),
            IconButton(
              icon: const Icon(Icons.watch),
              onPressed: () => _exportToAppleWatch(plan),
            ),
          ],
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
  }

  void _editPlan(TrainingPlan plan) {
    final nameController = TextEditingController(text: plan.name);
    final descController = TextEditingController(text: plan.description);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('编辑训练计划'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: '计划名称'),
            ),
            TextField(
              controller: descController,
              decoration: const InputDecoration(labelText: '计划描述'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              final newPlan = TrainingPlan(
                name: nameController.text,
                description: descController.text,
                sets: plan.sets,
              );
              setState(() {
                _userPlans.add(newPlan);
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('已保存为"${newPlan.name}"')),
              );
            },
            child: const Text('保存'),
          ),
        ],
      ),
    );
  }

  void _deletePlan(TrainingPlan plan) {
    setState(() {
      _userPlans.remove(plan);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('已删除"${plan.name}"')),
    );
  }

  void _navigateToCreatePlan() async {
    final result = await Navigator.push<TrainingPlan>(
      context,
      MaterialPageRoute(
        builder: (context) => CreatePlanPage(presetPlans: _presetPlans),
      ),
    );
    
    if (result != null) {
      setState(() {
        _userPlans.add(result);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('已保存计划"${result.name}"')),
      );
    }
  }

  void _exportToAppleWatch(TrainingPlan plan) async {
    try {
      // 请求健康数据权限
      final types = [
        HealthDataType.WORKOUT,
        HealthDataType.DISTANCE_SWIMMING,
        HealthDataType.SWIMMING_STROKE_COUNT,
      ];
      
      final permissions = [
        HealthDataAccess.WRITE,
        HealthDataAccess.WRITE,
        HealthDataAccess.WRITE,
      ];
      
      bool requested = await Health().requestAuthorization(types, permissions: permissions);
      
      if (requested) {
        // 计算总距离和总时间
        int totalDistance = 0;
        int totalDuration = 0;
        
        for (final set in plan.sets) {
          if (set.category != 'cooldown') {
            totalDistance += (set.distance * set.rounds).toInt();
            // 估算游泳时间：每100米约2分钟
            totalDuration += ((set.distance * set.rounds * 2 * 60) / 100).toInt();
            totalDuration += set.rest; // 加上休息时间
          } else {
            totalDuration += set.rest; // 放松时间
          }
        }
        
        final now = DateTime.now();
        final startTime = now;
        final endTime = now.add(Duration(seconds: totalDuration));
        
        // 写入游泳锻炼数据
        bool success = await Health().writeWorkoutData(
          HealthWorkoutActivityType.SWIMMING_OPEN_WATER,
          startTime,
          endTime,
          totalEnergyBurned: totalDistance * 3, // 估算卡路里
          totalEnergyBurnedUnit: HealthDataUnit.KILOCALORIE,
          totalDistance: totalDistance,
          totalDistanceUnit: HealthDataUnit.METER,
        );
        
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('"${plan.name}"已成功导出到Apple Watch')),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('导出失败，请重试')),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('需要健康数据权限才能导出到Apple Watch')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('导出出错：$e')),
      );
    }
  }
}