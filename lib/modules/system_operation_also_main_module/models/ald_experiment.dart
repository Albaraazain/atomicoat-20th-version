import 'package:cloud_firestore/cloud_firestore.dart';
import 'experiment.dart';

class ALDExperiment extends Experiment {
  final int totalCycles;
  final Map<String, dynamic> precursorConfig;
  final Map<String, dynamic> substrateConfig;
  final double targetThickness;
  final Map<String, double> chamberConditions;
  final Map<String, dynamic> purgeConfig;
  final List<String> monitoredParameters;
  final Map<String, dynamic> cycleParameters;

  ALDExperiment({
    required String id,
    required String name,
    required String description,
    required String createdBy,
    required DateTime createdAt,
    required List<ExperimentStep> recipeSequence,
    required this.totalCycles,
    required this.precursorConfig,
    required this.substrateConfig,
    required this.targetThickness,
    required this.chamberConditions,
    required this.purgeConfig,
    required this.monitoredParameters,
    required this.cycleParameters,
    Map<String, dynamic>? parameters,
    String status = 'pending',
  }) : super(
    id: id,
    name: name,
    description: description,
    createdBy: createdBy,
    createdAt: createdAt,
    recipeSequence: recipeSequence,
    parameters: parameters,
    status: status,
  );

  factory ALDExperiment.fromJson(Map<String, dynamic> json) {
    return ALDExperiment(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      createdBy: json['createdBy'] as String,
      createdAt: (json['createdAt'] as Timestamp).toDate(),
      recipeSequence: (json['recipeSequence'] as List)
          .map((step) => ExperimentStep.fromJson(step))
          .toList(),
      totalCycles: json['totalCycles'] as int,
      precursorConfig: json['precursorConfig'] as Map<String, dynamic>,
      substrateConfig: json['substrateConfig'] as Map<String, dynamic>,
      targetThickness: (json['targetThickness'] as num).toDouble(),
      chamberConditions: Map<String, double>.from(json['chamberConditions']),
      purgeConfig: json['purgeConfig'] as Map<String, dynamic>,
      monitoredParameters: List<String>.from(json['monitoredParameters']),
      cycleParameters: json['cycleParameters'] as Map<String, dynamic>,
      parameters: json['parameters'] as Map<String, dynamic>?,
      status: json['status'] as String,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    ...super.toJson(),
    'totalCycles': totalCycles,
    'precursorConfig': precursorConfig,
    'substrateConfig': substrateConfig,
    'targetThickness': targetThickness,
    'chamberConditions': chamberConditions,
    'purgeConfig': purgeConfig,
    'monitoredParameters': monitoredParameters,
    'cycleParameters': cycleParameters,
  };

  // Helper method to validate ALD parameters
  bool validateParameters() {
    // Validate precursor configuration
    if (!precursorConfig.containsKey('precursorA') ||
        !precursorConfig.containsKey('precursorB')) {
      return false;
    }

    // Validate chamber conditions
    if (!chamberConditions.containsKey('temperature') ||
        !chamberConditions.containsKey('pressure')) {
      return false;
    }

    // Validate purge configuration
    if (!purgeConfig.containsKey('purgeTimeA') ||
        !purgeConfig.containsKey('purgeTimeB')) {
      return false;
    }

    // Validate cycle parameters
    if (!cycleParameters.containsKey('exposureTimeA') ||
        !cycleParameters.containsKey('exposureTimeB')) {
      return false;
    }

    return true;
  }

  // Helper method to get cycle sequence
  List<Map<String, dynamic>> generateCycleSequence() {
    return [
      {
        'step': 'precursorA',
        'duration': cycleParameters['exposureTimeA'],
        'type': 'exposure',
      },
      {
        'step': 'purgeA',
        'duration': purgeConfig['purgeTimeA'],
        'type': 'purge',
      },
      {
        'step': 'precursorB',
        'duration': cycleParameters['exposureTimeB'],
        'type': 'exposure',
      },
      {
        'step': 'purgeB',
        'duration': purgeConfig['purgeTimeB'],
        'type': 'purge',
      },
    ];
  }
}