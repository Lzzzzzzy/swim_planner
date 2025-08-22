import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/swim_record.dart';

class CreatePlanPage extends StatefulWidget {
  final List<TrainingPlan> presetPlans;

  const CreatePlanPage({super.key, required this.presetPlans});

  @override
  State<CreatePlanPage> createState() => _CreatePlanPageState();
}

class _CreatePlanPageState extends State<CreatePlanPage> {
  TrainingPlan? selectedPlan;
  final nameController = TextEditingController();
  final descController = TextEditingController();
  List<TrainingSet> customSets = [];
  TrainingSet warmupSet = TrainingSet(distance: 100, type: '自由泳', rest: 40, category: 'warmup');
  TrainingSet cooldownSet = TrainingSet(distance: 0, type: '放松', rest: 600, category: 'cooldown'); // 10分钟=600秒
  bool isCustomPlan = false;
  bool hasChanges = false;

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (hasChanges) {
          return await _showExitDialog();
        }
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('新增训练计划'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () async {
              if (hasChanges) {
                final shouldExit = await _showExitDialog();
                if (shouldExit) Navigator.pop(context);
              } else {
                Navigator.pop(context);
              }
            },
          ),
        ),
        body: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  const Text('选择预设计划', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Card(
                    color: isCustomPlan ? Colors.blue.shade50 : null,
                    child: ListTile(
                      leading: const Icon(Icons.create),
                      title: const Text('自定义计划'),
                      subtitle: const Text('创建全新的训练计划'),
                      onTap: () {
                        setState(() {
                          isCustomPlan = true;
                          selectedPlan = null;
                          nameController.clear();
                          descController.clear();
                          customSets = [TrainingSet(distance: 100, type: '蛙泳', rest: 30, rounds: 1)];
                          hasChanges = true;
                        });
                      },
                    ),
                  ),
                  ...widget.presetPlans.map((plan) => Card(
                    color: selectedPlan == plan ? Colors.blue.shade50 : null,
                    child: ListTile(
                      leading: const Icon(Icons.fitness_center),
                      title: Text(plan.name),
                      subtitle: Text(plan.description),
                      onTap: () {
                        setState(() {
                          selectedPlan = plan;
                          isCustomPlan = false;
                          nameController.text = plan.name;
                          descController.text = plan.description;
                          customSets = List.from(plan.sets);
                          hasChanges = true;
                        });
                      },
                    ),
                  )),
                  if (selectedPlan != null || isCustomPlan) ...[
                    const SizedBox(height: 20),
                    const Text('计划详情', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    TextField(
                      controller: nameController,
                      decoration: const InputDecoration(labelText: '计划名称'),
                      onChanged: (_) => hasChanges = true,
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: descController,
                      decoration: const InputDecoration(labelText: '计划描述'),
                      onChanged: (_) => hasChanges = true,
                    ),
                    const SizedBox(height: 16),
                    const Text('热身', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    _buildWarmupEditor(),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('正式训练', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        IconButton(
                          icon: const Icon(Icons.add),
                          onPressed: _addTrainingSet,
                        ),
                      ],
                    ),
                    ...customSets.asMap().entries.map((entry) => _buildSetEditor(entry.key, entry.value)),
                    const SizedBox(height: 16),
                    const Text('放松', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    _buildCooldownEditor(),
                  ],
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () async {
                        if (hasChanges) {
                          final shouldExit = await _showExitDialog();
                          if (shouldExit) Navigator.pop(context);
                        } else {
                          Navigator.pop(context);
                        }
                      },
                      child: const Text('返回'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: (selectedPlan != null || isCustomPlan) ? _savePlan : null,
                      child: const Text('确认'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<bool> _showExitDialog() async {
    return await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('提示'),
        content: const Text('您的计划还未保存，确认返回吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('确认'),
          ),
        ],
      ),
    ) ?? false;
  }

  List<int> get _distanceOptions {
    return List.generate(40, (index) => (index + 1) * 25);
  }

  List<String> get _strokeOptions => ['蛙泳', '自由泳', '仰泳', '蝶泳', '混合泳'];
  List<int> get _roundsOptions => List.generate(10, (index) => index + 1);

  Widget _buildSetEditor(int index, TrainingSet set) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<int>(
                    decoration: const InputDecoration(labelText: '距离(m)'),
                    value: _distanceOptions.contains(set.distance) ? set.distance : 100,
                    items: _distanceOptions.map((distance) => DropdownMenuItem(
                      value: distance,
                      child: Text('${distance}m'),
                    )).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        customSets[index] = TrainingSet(
                          distance: value,
                          type: set.type,
                          rest: set.rest,
                          rounds: set.rounds,
                        );
                        hasChanges = true;
                        setState(() {});
                      }
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    decoration: const InputDecoration(labelText: '泳姿'),
                    value: _strokeOptions.contains(set.type) ? set.type : '蛙泳',
                    items: _strokeOptions.map((stroke) => DropdownMenuItem(
                      value: stroke,
                      child: Text(stroke),
                    )).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        customSets[index] = TrainingSet(
                          distance: set.distance,
                          type: value,
                          rest: set.rest,
                          rounds: set.rounds,
                        );
                        hasChanges = true;
                        setState(() {});
                      }
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<int>(
                    decoration: const InputDecoration(labelText: '循环次数'),
                    value: _roundsOptions.contains(set.rounds) ? set.rounds : 1,
                    items: _roundsOptions.map((rounds) => DropdownMenuItem(
                      value: rounds,
                      child: Text('${rounds}次'),
                    )).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        customSets[index] = TrainingSet(
                          distance: set.distance,
                          type: set.type,
                          rest: set.rest,
                          rounds: value,
                        );
                        hasChanges = true;
                        setState(() {});
                      }
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    decoration: const InputDecoration(labelText: '休息(秒)'),
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    controller: TextEditingController(text: set.rest.toString()),
                    onChanged: (value) {
                      customSets[index] = TrainingSet(
                        distance: set.distance,
                        type: set.type,
                        rest: int.tryParse(value) ?? set.rest,
                        rounds: set.rounds,
                      );
                      hasChanges = true;
                    },
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () {
                    setState(() {
                      customSets.removeAt(index);
                      hasChanges = true;
                    });
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _addTrainingSet() {
    setState(() {
      customSets.add(TrainingSet(distance: 100, type: '蛙泳', rest: 30, rounds: 1));
      hasChanges = true;
    });
  }

  Widget _buildWarmupEditor() {
    return Card(
      color: Colors.orange.shade50,
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<int>(
                    decoration: const InputDecoration(labelText: '距离(m)'),
                    value: _distanceOptions.contains(warmupSet.distance) ? warmupSet.distance : 100,
                    items: _distanceOptions.map((distance) => DropdownMenuItem(
                      value: distance,
                      child: Text('${distance}m'),
                    )).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        warmupSet = TrainingSet(
                          distance: value,
                          type: warmupSet.type,
                          rest: warmupSet.rest,
                          category: 'warmup',
                        );
                        hasChanges = true;
                        setState(() {});
                      }
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    decoration: const InputDecoration(labelText: '泳姿'),
                    value: _strokeOptions.contains(warmupSet.type) ? warmupSet.type : '自由泳',
                    items: _strokeOptions.map((stroke) => DropdownMenuItem(
                      value: stroke,
                      child: Text(stroke),
                    )).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        warmupSet = TrainingSet(
                          distance: warmupSet.distance,
                          type: value,
                          rest: warmupSet.rest,
                          category: 'warmup',
                        );
                        hasChanges = true;
                        setState(() {});
                      }
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            TextField(
              decoration: const InputDecoration(labelText: '休息(秒)'),
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              controller: TextEditingController(text: warmupSet.rest.toString()),
              onChanged: (value) {
                warmupSet = TrainingSet(
                  distance: warmupSet.distance,
                  type: warmupSet.type,
                  rest: int.tryParse(value) ?? warmupSet.rest,
                  category: 'warmup',
                );
                hasChanges = true;
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCooldownEditor() {
    return Card(
      color: Colors.blue.shade50,
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: TextField(
          decoration: const InputDecoration(labelText: '放松时长(分钟)'),
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          controller: TextEditingController(text: (cooldownSet.rest ~/ 60).toString()),
          onChanged: (value) {
            final minutes = int.tryParse(value) ?? 10;
            cooldownSet = TrainingSet(
              distance: 0,
              type: '放松',
              rest: minutes * 60,
              category: 'cooldown',
            );
            hasChanges = true;
          },
        ),
      ),
    );
  }

  void _savePlan() {
    if (nameController.text.isNotEmpty) {
      final allSets = [warmupSet, ...customSets, cooldownSet];
      final newPlan = TrainingPlan(
        name: nameController.text,
        description: descController.text,
        sets: allSets,
      );
      Navigator.pop(context, newPlan);
    }
  }
}