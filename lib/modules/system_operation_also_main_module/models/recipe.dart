// lib/modules/system_operation_also_main_module/models/recipe.dart

import 'package:cloud_firestore/cloud_firestore.dart';

class Recipe {
  String id;
  String name;
  List<RecipeStep> steps;
  String substrate;
  double chamberTemperatureSetPoint;
  double pressureSetPoint;
  int version;
  DateTime lastModified;
  String machineId;         // ID of the machine this recipe is for
  String createdBy;         // ID of the user who created the recipe
  DateTime createdAt;       // When the recipe was created
  bool isPublic;           // Whether other researchers can see this recipe
  String? description;     // Optional description of what this recipe does

  Recipe({
    required this.id,
    required this.name,
    required this.steps,
    required this.substrate,
    required this.machineId,
    required this.createdBy,
    this.chamberTemperatureSetPoint = 150.0,
    this.pressureSetPoint = 1.0,
    this.version = 1,
    DateTime? lastModified,
    DateTime? createdAt,
    this.isPublic = false,
    this.description,
  }) : this.lastModified = lastModified ?? DateTime.now(),
       this.createdAt = createdAt ?? DateTime.now();

  factory Recipe.fromJson(Map<String, dynamic> json) {
    return Recipe(
      id: json['id'] as String,
      name: json['name'] as String,
      steps: (json['steps'] as List<dynamic>)
          .map((e) => RecipeStep.fromJson(e as Map<String, dynamic>))
          .toList(),
      substrate: json['substrate'] as String,
      machineId: json['machineId'] as String,
      createdBy: json['createdBy'] as String,
      chamberTemperatureSetPoint: json['chamberTemperatureSetPoint'] as double? ?? 150.0,
      pressureSetPoint: json['pressureSetPoint'] as double? ?? 1.0,
      version: json['version'] as int? ?? 1,
      lastModified: (json['lastModified'] as Timestamp).toDate(),
      createdAt: json['createdAt'] != null
          ? (json['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
      isPublic: json['isPublic'] as bool? ?? false,
      description: json['description'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'steps': steps.map((e) => e.toJson()).toList(),
    'substrate': substrate,
    'machineId': machineId,
    'createdBy': createdBy,
    'chamberTemperatureSetPoint': chamberTemperatureSetPoint,
    'pressureSetPoint': pressureSetPoint,
    'version': version,
    'lastModified': Timestamp.fromDate(lastModified),
    'createdAt': Timestamp.fromDate(createdAt),
    'isPublic': isPublic,
    'description': description,
  };
}

class RecipeStep {
  StepType type;
  Map<String, dynamic> parameters;
  List<RecipeStep>? subSteps;

  RecipeStep({
    required this.type,
    required this.parameters,
    this.subSteps,
  });

  factory RecipeStep.fromJson(Map<String, dynamic> json) {
    return RecipeStep(
      type: StepType.values.firstWhere((e) => e.toString() == 'StepType.${json['type']}'),
      parameters: Map<String, dynamic>.from(json['parameters']).map((key, value) {
        if (key == 'valveType' && value is String) {
          return MapEntry(key, ValveType.values.firstWhere((e) => e.toString() == 'ValveType.$value'));
        }
        return MapEntry(key, value);
      }),
      subSteps: json['subSteps'] != null
          ? (json['subSteps'] as List<dynamic>)
          .map((e) => RecipeStep.fromJson(e as Map<String, dynamic>))
          .toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'type': type.toString().split('.').last,
    'parameters': parameters.map((key, value) {
      if (value is ValveType) {
        return MapEntry(key, value.toString().split('.').last);
      }
      return MapEntry(key, value);
    }),
    'subSteps': subSteps?.map((e) => e.toJson()).toList(),
  };
}

enum StepType { loop, valve, purge, setParameter }

enum ValveType { valveA, valveB }


/*
class Recipe {
    /// Unique identifier for the recipe
    String id;
    /// Recipe name
    String name;
    /// Ordered list of recipe steps
    List<RecipeStep> steps;
    /// Substrate material
    String substrate;
    /// Target chamber temperature
    double chamberTemperatureSetPoint;
    /// Target pressure
    double pressureSetPoint;
    /// Recipe version number
    int version;
    /// Last modification timestamp
    DateTime lastModified;

    /// Constructor for creating a new recipe
    Recipe({
        required this.id,
        required this.name,
        required this.steps,
        required this.substrate,
        this.chamberTemperatureSetPoint = 150.0,
        this.pressureSetPoint = 1.0,
        this.version = 1,
        DateTime? lastModified,
    });
}

class RecipeStep {
    /// Type of recipe step (loop, valve, purge, setParameter)
    StepType type;
    /// Parameters specific to the step type
    Map<String, dynamic> parameters;
    /// Sub-steps for loop type steps
    List<RecipeStep>? subSteps;

    /// Constructor for creating a recipe step
    RecipeStep({
        required this.type,
        required this.parameters,
        this.subSteps,
    });
}
enum StepType { loop, valve, purge, setParameter }
enum ValveType { valveA, valveB }

*/
