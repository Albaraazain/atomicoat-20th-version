// lib/modules/system_operation_also_main_module/models/experiment.dart

import 'package:cloud_firestore/cloud_firestore.dart';

enum ExperimentStatus {
  planned,    // Experiment is planned but not started
  running,    // Experiment is currently running
  completed,  // Experiment completed successfully
  failed,     // Experiment failed or was aborted
}

class Experiment {
  final String id;                // Unique identifier for the experiment
  final String machineId;         // ID of the machine used
  final String researcherId;      // ID of the researcher conducting the experiment
  final String name;              // Name/title of the experiment
  final String recipeId;          // ID of the recipe being used
  final DateTime startTime;       // When the experiment started
  final DateTime? endTime;        // When the experiment ended (null if not ended)
  final ExperimentStatus status;  // Current status of the experiment
  final Map<String, dynamic> recipeParameters; // Copy of recipe parameters used
  final int totalCycles;          // Total number of ALD cycles planned
  final int? completedCycles;     // Number of cycles completed (null if not started)

  Experiment({
    required this.id,
    required this.machineId,
    required this.researcherId,
    required this.name,
    required this.recipeId,
    required this.startTime,
    this.endTime,
    this.status = ExperimentStatus.planned,
    required this.recipeParameters,
    required this.totalCycles,
    this.completedCycles,
  });

  factory Experiment.fromJson(Map<String, dynamic> json) {
    return Experiment(
      id: json['id'] as String,
      machineId: json['machineId'] as String,
      researcherId: json['researcherId'] as String,
      name: json['name'] as String,
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
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'machineId': machineId,
    'researcherId': researcherId,
    'name': name,
    'recipeId': recipeId,
    'startTime': Timestamp.fromDate(startTime),
    'endTime': endTime != null ? Timestamp.fromDate(endTime!) : null,
    'status': status.toString().split('.').last,
    'recipeParameters': recipeParameters,
    'totalCycles': totalCycles,
    'completedCycles': completedCycles,
  };

  Experiment copyWith({
    String? id,
    String? machineId,
    String? researcherId,
    String? name,
    String? recipeId,
    DateTime? startTime,
    DateTime? endTime,
    ExperimentStatus? status,
    Map<String, dynamic>? recipeParameters,
    int? totalCycles,
    int? completedCycles,
  }) {
    return Experiment(
      id: id ?? this.id,
      machineId: machineId ?? this.machineId,
      researcherId: researcherId ?? this.researcherId,
      name: name ?? this.name,
      recipeId: recipeId ?? this.recipeId,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      status: status ?? this.status,
      recipeParameters: recipeParameters ?? Map<String, dynamic>.from(this.recipeParameters),
      totalCycles: totalCycles ?? this.totalCycles,
      completedCycles: completedCycles ?? this.completedCycles,
    );
  }
}