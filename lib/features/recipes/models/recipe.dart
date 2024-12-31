import 'package:cloud_firestore/cloud_firestore.dart';

enum StepType {
  valve,
  purge,
  loop,
  setParameter,
}

class RecipeStep {
  final String id;
  final String name;
  final String description;
  final Map<String, dynamic> parameters;
  final StepType type;
  final List<RecipeStep>? subSteps;

  RecipeStep({
    required this.id,
    required this.name,
    required this.description,
    required this.parameters,
    required this.type,
    this.subSteps,
  });

  factory RecipeStep.fromMap(Map<String, dynamic> map) {
    return RecipeStep(
      id: map['id'],
      name: map['name'],
      description: map['description'],
      parameters: map['parameters'],
      type: StepType.values.firstWhere(
        (e) => e.toString() == 'StepType.${map['type']}',
        orElse: () => StepType.setParameter,
      ),
      subSteps: map['subSteps'] != null
        ? (map['subSteps'] as List).map((step) => RecipeStep.fromMap(step)).toList()
        : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'parameters': parameters,
      'type': type.toString().split('.').last,
      'subSteps': subSteps?.map((step) => step.toMap()).toList(),
    };
  }
}

class Recipe {
  final String id;
  final String name;
  final String description;
  final List<RecipeStep> steps;
  final bool isPublic;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final String createdBy;
  final String machineId;
  final String substrate;
  final double chamberTemperatureSetPoint;
  final double pressureSetPoint;

  Recipe({
    required this.id,
    required this.name,
    required this.description,
    required this.steps,
    this.isPublic = false,
    required this.createdAt,
    this.updatedAt,
    required this.createdBy,
    required this.machineId,
    required this.substrate,
    required this.chamberTemperatureSetPoint,
    required this.pressureSetPoint,
  });

  factory Recipe.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Recipe(
      id: doc.id,
      name: data['name'],
      description: data['description'],
      steps: (data['steps'] as List).map((step) =>
        RecipeStep.fromMap(step)
      ).toList(),
      isPublic: data['isPublic'] ?? false,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: data['updatedAt'] != null
        ? (data['updatedAt'] as Timestamp).toDate()
        : null,
      createdBy: data['createdBy'] ?? '',
      machineId: data['machineId'] ?? '',
      substrate: data['substrate'] ?? '',
      chamberTemperatureSetPoint: data['chamberTemperatureSetPoint'] ?? 0.0,
      pressureSetPoint: data['pressureSetPoint'] ?? 0.0,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'description': description,
      'steps': steps.map((step) => step.toMap()).toList(),
      'isPublic': isPublic,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': updatedAt != null
        ? Timestamp.fromDate(updatedAt!)
        : null,
    };
  }

  Recipe copyWith({
    String? id,
    String? name,
    String? description,
    List<RecipeStep>? steps,
    bool? isPublic,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? createdBy,
    String? machineId,
    String? substrate,
    double? chamberTemperatureSetPoint,
    double? pressureSetPoint,
  }) {
    return Recipe(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      steps: steps ?? this.steps,
      isPublic: isPublic ?? this.isPublic,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      createdBy: createdBy ?? this.createdBy,
      machineId: machineId ?? this.machineId,
      substrate: substrate ?? this.substrate,
      chamberTemperatureSetPoint: chamberTemperatureSetPoint ?? this.chamberTemperatureSetPoint,
      pressureSetPoint: pressureSetPoint ?? this.pressureSetPoint,
    );
  }

  static Recipe fromJson(Map<String, dynamic> json) {
    return Recipe(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      steps: (json['steps'] as List? ?? []).map((step) => RecipeStep.fromMap(step)).toList(),
      isPublic: json['isPublic'] ?? false,
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : DateTime.now(),
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
      createdBy: json['createdBy'] ?? '',
      machineId: json['machineId'] ?? '',
      substrate: json['substrate'] ?? '',
      chamberTemperatureSetPoint: (json['chamberTemperatureSetPoint'] ?? 0.0).toDouble(),
      pressureSetPoint: (json['pressureSetPoint'] ?? 0.0).toDouble(),
    );
  }

  factory Recipe.mock() {
    return Recipe(
      id: 'recipe_1',
      name: 'Standard ALD Process',
      description: 'Basic ALD process for thin film deposition',
      createdBy: 'operator_1',
      machineId: 'machine_1',
      substrate: 'Silicon Wafer',
      chamberTemperatureSetPoint: 200.0,
      pressureSetPoint: 1.0,
      createdAt: DateTime.now().subtract(const Duration(days: 30)),
      updatedAt: DateTime.now(),
      steps: [
        RecipeStep(
          id: 'step_1',
          name: 'Precursor A Pulse',
          description: 'Introduce precursor A into chamber',
          type: StepType.valve,
          parameters: {
            'duration': 0.5,
            'temperature': 200.0,
            'pressure': 1.0,
          },
          subSteps: [],
        ),
        RecipeStep(
          id: 'step_2',
          name: 'Purge',
          description: 'Clear chamber of precursor A',
          type: StepType.purge,
          parameters: {
            'duration': 2.0,
            'flowRate': 100.0,
          },
          subSteps: [],
        ),
      ],
      isPublic: true,
    );
  }
}
