import 'package:flutter/foundation.dart';
import '../../../features/recipes/models/recipe.dart';
import 'process_data_point.dart';

enum ProcessStatus {
  preparing,
  running,
  paused,
  completed,
  failed,
  aborted,
}

class ProcessExecution {
  final String id;
  final String machineId;
  final Recipe recipe;
  final DateTime startTime;
  final DateTime? endTime;
  final String operatorId;
  final ProcessStatus status;
  final int currentStepIndex;
  final List<ProcessDataPoint> dataPoints;
  final Map<String, dynamic> parameters;
  final String? errorMessage;

  ProcessExecution({
    required this.id,
    required this.machineId,
    required this.recipe,
    required this.startTime,
    this.endTime,
    required this.operatorId,
    required this.status,
    required this.currentStepIndex,
    required this.dataPoints,
    required this.parameters,
    this.errorMessage,
  });

  bool get isActive => status == ProcessStatus.running || status == ProcessStatus.paused;
  bool get isCompleted => status == ProcessStatus.completed;
  bool get hasFailed => status == ProcessStatus.failed;
  bool get wasAborted => status == ProcessStatus.aborted;

  Duration get duration {
    final end = endTime ?? DateTime.now();
    return end.difference(startTime);
  }

  double get progress {
    if (isCompleted || hasFailed || wasAborted) return 1.0;
    return currentStepIndex / recipe.steps.length;
  }

  String get currentStepName {
    if (currentStepIndex >= recipe.steps.length) return 'Completed';
    return recipe.steps[currentStepIndex].name;
  }

  List<ProcessDataPoint> getParameterData(String parameter) {
    return dataPoints.where((point) => point.parameter == parameter).toList();
  }

  Map<String, List<ProcessDataPoint>> get parameterDataSeries {
    final series = <String, List<ProcessDataPoint>>{};
    for (final point in dataPoints) {
      series.putIfAbsent(point.parameter, () => []).add(point);
    }
    return series;
  }

  ProcessExecution copyWith({
    String? id,
    String? machineId,
    Recipe? recipe,
    DateTime? startTime,
    DateTime? endTime,
    String? operatorId,
    ProcessStatus? status,
    int? currentStepIndex,
    List<ProcessDataPoint>? dataPoints,
    Map<String, dynamic>? parameters,
    String? errorMessage,
  }) {
    return ProcessExecution(
      id: id ?? this.id,
      machineId: machineId ?? this.machineId,
      recipe: recipe ?? this.recipe,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      operatorId: operatorId ?? this.operatorId,
      status: status ?? this.status,
      currentStepIndex: currentStepIndex ?? this.currentStepIndex,
      dataPoints: dataPoints ?? this.dataPoints,
      parameters: parameters ?? this.parameters,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'machineId': machineId,
      'recipe': recipe.toFirestore(),
      'startTime': startTime.toIso8601String(),
      'endTime': endTime?.toIso8601String(),
      'operatorId': operatorId,
      'status': status.toString(),
      'currentStepIndex': currentStepIndex,
      'dataPoints': dataPoints.map((p) => p.toMap()).toList(),
      'parameters': parameters,
      'errorMessage': errorMessage,
    };
  }

  factory ProcessExecution.fromMap(Map<String, dynamic> map) {
    return ProcessExecution(
      id: map['id'],
      machineId: map['machineId'],
      recipe: Recipe.fromJson(map['recipe']),
      startTime: DateTime.parse(map['startTime']),
      endTime: map['endTime'] != null ? DateTime.parse(map['endTime']) : null,
      operatorId: map['operatorId'],
      status: ProcessStatus.values.firstWhere(
        (s) => s.toString() == map['status'],
        orElse: () => ProcessStatus.failed,
      ),
      currentStepIndex: map['currentStepIndex'],
      dataPoints: (map['dataPoints'] as List)
          .map((p) => ProcessDataPoint.fromMap(p))
          .toList(),
      parameters: Map<String, dynamic>.from(map['parameters']),
      errorMessage: map['errorMessage'],
    );
  }

  @override
  String toString() => 'ProcessExecution(id: $id, recipe: ${recipe.name}, status: $status)';
}
