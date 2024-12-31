import 'package:flutter/foundation.dart';
import '../../../features/recipes/models/recipe.dart';
import '../../../features/process/models/process_execution.dart';
import '../../../features/process/models/process_data_point.dart';
import 'experiment_metadata.dart';
import 'experiment_result.dart';

class Experiment {
  final String id;
  final String machineId;
  final Recipe recipe;
  final DateTime startTime;
  final DateTime endTime;
  final String operatorId;
  final ProcessStatus status;
  final List<ProcessDataPoint> dataPoints;
  final ExperimentMetadata metadata;
  final ExperimentResult? result;
  final String? notes;

  Experiment({
    required this.id,
    required this.machineId,
    required this.recipe,
    required this.startTime,
    required this.endTime,
    required this.operatorId,
    required this.status,
    required this.dataPoints,
    required this.metadata,
    this.result,
    this.notes,
  });

  Duration get duration => endTime.difference(startTime);

  bool get isSuccessful => status == ProcessStatus.completed &&
    (result?.qualityScore ?? 0) >= metadata.qualityThreshold;

  Map<String, List<ProcessDataPoint>> get parameterDataSeries {
    final series = <String, List<ProcessDataPoint>>{};
    for (final point in dataPoints) {
      series.putIfAbsent(point.parameter, () => []).add(point);
    }
    return series;
  }

  List<ProcessDataPoint> getParameterData(String parameter) {
    return dataPoints.where((point) => point.parameter == parameter).toList();
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'machineId': machineId,
      'recipe': recipe.toFirestore(),
      'startTime': startTime.toIso8601String(),
      'endTime': endTime.toIso8601String(),
      'operatorId': operatorId,
      'status': status.toString(),
      'dataPoints': dataPoints.map((p) => p.toMap()).toList(),
      'metadata': metadata.toMap(),
      'result': result?.toMap(),
      'notes': notes,
    };
  }

  factory Experiment.fromMap(Map<String, dynamic> map) {
    return Experiment(
      id: map['id'],
      machineId: map['machineId'],
      recipe: Recipe.fromJson(map['recipe']),
      startTime: DateTime.parse(map['startTime']),
      endTime: DateTime.parse(map['endTime']),
      operatorId: map['operatorId'],
      status: ProcessStatus.values.firstWhere(
        (s) => s.toString() == map['status'],
        orElse: () => ProcessStatus.failed,
      ),
      dataPoints: (map['dataPoints'] as List)
          .map((p) => ProcessDataPoint.fromMap(p))
          .toList(),
      metadata: ExperimentMetadata.fromMap(map['metadata']),
      result: map['result'] != null
          ? ExperimentResult.fromMap(map['result'])
          : null,
      notes: map['notes'],
    );
  }

  factory Experiment.fromProcessExecution(
    ProcessExecution process,
    ExperimentMetadata metadata,
    ExperimentResult? result,
  ) {
    return Experiment(
      id: process.id,
      machineId: process.machineId,
      recipe: process.recipe,
      startTime: process.startTime,
      endTime: process.endTime!,
      operatorId: process.operatorId,
      status: process.status,
      dataPoints: process.dataPoints,
      metadata: metadata,
      result: result,
    );
  }

  @override
  String toString() => 'Experiment(id: $id, recipe: ${recipe.name}, status: $status)';
}
