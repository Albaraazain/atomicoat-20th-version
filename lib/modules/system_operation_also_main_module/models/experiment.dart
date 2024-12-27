// lib/modules/system_operation_also_main_module/models/experiment.dart

import 'package:cloud_firestore/cloud_firestore.dart';

enum ExperimentStatus {
  planned,    // Experiment is planned but not started
  running,    // Experiment is currently running
  paused,     // Experiment is temporarily paused
  completed,  // Experiment completed successfully
  failed,     // Experiment failed or was aborted
  analyzed    // Experiment has been analyzed
}

class Experiment {
  final String id;                // Unique identifier for the experiment
  final String machineId;         // ID of the machine used
  final String researcherId;      // ID of the researcher conducting the experiment
  final String name;              // Name/title of the experiment
  final String description;       // Description of the experiment
  final String recipeId;          // ID of the recipe being used
  final DateTime startTime;       // When the experiment started
  final DateTime? endTime;        // When the experiment ended (null if not ended)
  final ExperimentStatus status;  // Current status of the experiment
  final Map<String, dynamic> recipeParameters; // Copy of recipe parameters used
  final int totalCycles;          // Total number of ALD cycles planned
  final int? completedCycles;     // Number of cycles completed (null if not started)
  final Map<String, dynamic> substrate; // Substrate information
  final Map<String, dynamic> targetProperties; // Target film properties
  final Map<String, dynamic>? results;  // Results after completion
  final String? notes;            // Additional notes
  final Map<String, dynamic> monitoringConfig; // Configuration for component monitoring
  final DateTime lastUpdated;     // Last time the experiment was updated

  Experiment({
    required this.id,
    required this.machineId,
    required this.researcherId,
    required this.name,
    required this.description,
    required this.recipeId,
    required this.startTime,
    this.endTime,
    this.status = ExperimentStatus.planned,
    required this.recipeParameters,
    required this.totalCycles,
    this.completedCycles,
    required this.substrate,
    required this.targetProperties,
    this.results,
    this.notes,
    required this.monitoringConfig,
    required this.lastUpdated,
  });

  factory Experiment.fromJson(Map<String, dynamic> json) {
    return Experiment(
      id: json['id'] as String,
      machineId: json['machineId'] as String,
      researcherId: json['researcherId'] as String,
      name: json['name'] as String,
      description: json['description'] as String? ?? '',
      recipeId: json['recipeId'] as String,
      startTime: (json['startTime'] as Timestamp).toDate(),
      endTime: json['endTime'] != null ? (json['endTime'] as Timestamp).toDate() : null,
      status: ExperimentStatus.values.firstWhere(
        (e) => e.toString() == 'ExperimentStatus.${json['status']}',
        orElse: () => ExperimentStatus.planned,
      ),
      recipeParameters: Map<String, dynamic>.from(json['recipeParameters'] as Map),
      totalCycles: json['totalCycles'] as int,
      completedCycles: json['completedCycles'] as int?,
      substrate: Map<String, dynamic>.from(json['substrate'] as Map? ?? {}),
      targetProperties: Map<String, dynamic>.from(json['targetProperties'] as Map? ?? {}),
      results: json['results'] != null ? Map<String, dynamic>.from(json['results'] as Map) : null,
      notes: json['notes'] as String?,
      monitoringConfig: Map<String, dynamic>.from(json['monitoringConfig'] as Map? ?? {}),
      lastUpdated: (json['lastUpdated'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'machineId': machineId,
    'researcherId': researcherId,
    'name': name,
    'description': description,
    'recipeId': recipeId,
    'startTime': Timestamp.fromDate(startTime),
    'endTime': endTime != null ? Timestamp.fromDate(endTime!) : null,
    'status': status.toString().split('.').last,
    'recipeParameters': recipeParameters,
    'totalCycles': totalCycles,
    'completedCycles': completedCycles,
    'substrate': substrate,
    'targetProperties': targetProperties,
    'results': results,
    'notes': notes,
    'monitoringConfig': monitoringConfig,
    'lastUpdated': Timestamp.fromDate(lastUpdated),
  };

  Experiment copyWith({
    String? id,
    String? machineId,
    String? researcherId,
    String? name,
    String? description,
    String? recipeId,
    DateTime? startTime,
    DateTime? endTime,
    ExperimentStatus? status,
    Map<String, dynamic>? recipeParameters,
    int? totalCycles,
    int? completedCycles,
    Map<String, dynamic>? substrate,
    Map<String, dynamic>? targetProperties,
    Map<String, dynamic>? results,
    String? notes,
    Map<String, dynamic>? monitoringConfig,
    DateTime? lastUpdated,
  }) {
    return Experiment(
      id: id ?? this.id,
      machineId: machineId ?? this.machineId,
      researcherId: researcherId ?? this.researcherId,
      name: name ?? this.name,
      description: description ?? this.description,
      recipeId: recipeId ?? this.recipeId,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      status: status ?? this.status,
      recipeParameters: recipeParameters ?? Map<String, dynamic>.from(this.recipeParameters),
      totalCycles: totalCycles ?? this.totalCycles,
      completedCycles: completedCycles ?? this.completedCycles,
      substrate: substrate ?? Map<String, dynamic>.from(this.substrate),
      targetProperties: targetProperties ?? Map<String, dynamic>.from(this.targetProperties),
      results: results ?? (this.results != null ? Map<String, dynamic>.from(this.results!) : null),
      notes: notes ?? this.notes,
      monitoringConfig: monitoringConfig ?? Map<String, dynamic>.from(this.monitoringConfig),
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }
}