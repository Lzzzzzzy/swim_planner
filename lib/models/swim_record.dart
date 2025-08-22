class SwimRecord {
  final DateTime date;
  final double distance;
  final int duration;
  final double calories;
  final double pace;
  final int heartRate;
  final int strokeCount;

  SwimRecord({
    required this.date,
    required this.distance,
    required this.duration,
    required this.calories,
    required this.pace,
    required this.heartRate,
    required this.strokeCount,
  });
}

class TrainingPlan {
  final String name;
  final String description;
  final List<TrainingSet> sets;

  TrainingPlan({
    required this.name,
    required this.description,
    required this.sets,
  });
}

class TrainingSet {
  final int distance;
  final String type;
  final int rest;
  final int rounds;
  final String category; // 'warmup', 'main', 'cooldown'

  TrainingSet({
    required this.distance,
    required this.type,
    required this.rest,
    this.rounds = 1,
    this.category = 'main',
  });
}