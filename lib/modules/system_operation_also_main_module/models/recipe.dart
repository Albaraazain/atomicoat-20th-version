// lib/modules/system_operation_also_main_module/models/recipe.dart

import 'package:cloud_firestore/cloud_firestore.dart';

enum StepType { valve, purge, loop, setParameter }

class RecipeStep {
  final StepType type;
  final Map<String, dynamic> parameters;
  final List<RecipeStep>? subSteps;

  RecipeStep({
    required this.type,
    required this.parameters,
    this.subSteps,
  });

  Map<String, dynamic> toJson() {
    return {
      'type': type.toString(),
      'parameters': parameters,
      if (subSteps != null)
        'subSteps': subSteps!.map((step) => step.toJson()).toList(),
    };
  }

  factory RecipeStep.fromJson(Map<String, dynamic> json) {
    return RecipeStep(
      type: StepType.values.firstWhere(
        (e) => e.toString() == json['type'],
      ),
      parameters: Map<String, dynamic>.from(json['parameters']),
      subSteps: json['subSteps'] != null
          ? List<RecipeStep>.from(
              json['subSteps'].map((x) => RecipeStep.fromJson(x)))
          : null,
    );
  }
}

class Recipe {
  String id;
  String name;
  String? description;
  String createdBy;
  DateTime createdAt;
  String machineId;
  bool isPublic;
  String substrate;
  double chamberTemperatureSetPoint;
  double pressureSetPoint;
  List<RecipeStep> steps;

  Recipe({
    required this.id,
    required this.name,
    this.description,
    required this.createdBy,
    required this.createdAt,
    required this.machineId,
    required this.isPublic,
    required this.substrate,
    required this.chamberTemperatureSetPoint,
    required this.pressureSetPoint,
    required this.steps,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'createdBy': createdBy,
      'createdAt': Timestamp.fromDate(createdAt),
      'machineId': machineId,
      'isPublic': isPublic,
      'substrate': substrate,
      'chamberTemperatureSetPoint': chamberTemperatureSetPoint,
      'pressureSetPoint': pressureSetPoint,
      'steps': steps.map((step) => step.toJson()).toList(),
    };
  }

  factory Recipe.fromJson(Map<String, dynamic> json) {
    return Recipe(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      createdBy: json['createdBy'],
      createdAt: (json['createdAt'] as Timestamp).toDate(),
      machineId: json['machineId'],
      isPublic: json['isPublic'],
      substrate: json['substrate'],
      chamberTemperatureSetPoint: json['chamberTemperatureSetPoint'].toDouble(),
      pressureSetPoint: json['pressureSetPoint'].toDouble(),
      steps: List<RecipeStep>.from(
        json['steps'].map((x) => RecipeStep.fromJson(x)),
      ),
    );
  }
}
