import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import '../../../features/recipes/models/recipe.dart';
import '../models/process_execution.dart';
import '../models/process_data_point.dart';

class ProcessProvider with ChangeNotifier {
  List<ProcessExecution> getMockProcesses() {
    return [
      ProcessExecution(
        id: 'process_1',
        machineId: 'machine_1',
        recipe: Recipe.mock(),
        startTime: DateTime.now().subtract(const Duration(hours: 2)),
        endTime: DateTime.now().subtract(const Duration(hours: 1)),
        operatorId: 'operator_1',
        status: ProcessStatus.completed,
        currentStepIndex: 5,
        dataPoints: _generateMockDataPoints(),
        parameters: {
          'temperature': 250.0,
          'pressure': 1.2,
          'flowRate': 100.0,
        },
      ),
      ProcessExecution(
        id: 'process_2',
        machineId: 'machine_1',
        recipe: Recipe.mock(),
        startTime: DateTime.now().subtract(const Duration(minutes: 30)),
        operatorId: 'operator_1',
        status: ProcessStatus.running,
        currentStepIndex: 2,
        dataPoints: _generateMockDataPoints(),
        parameters: {
          'temperature': 200.0,
          'pressure': 1.0,
          'flowRate': 80.0,
        },
      ),
      ProcessExecution(
        id: 'process_3',
        machineId: 'machine_2',
        recipe: Recipe.mock(),
        startTime: DateTime.now().subtract(const Duration(hours: 3)),
        endTime: DateTime.now().subtract(const Duration(hours: 2, minutes: 30)),
        operatorId: 'operator_2',
        status: ProcessStatus.failed,
        currentStepIndex: 3,
        dataPoints: _generateMockDataPoints(),
        parameters: {
          'temperature': 180.0,
          'pressure': 0.8,
          'flowRate': 90.0,
        },
        errorMessage: 'Temperature exceeded safety threshold',
      ),
    ];
  }

  List<ProcessDataPoint> _generateMockDataPoints() {
    final points = <ProcessDataPoint>[];
    final now = DateTime.now();

    // Generate temperature data points
    for (int i = 0; i < 60; i++) {
      points.add(
        ProcessDataPoint(
          parameter: 'temperature',
          value: 200.0 + (i * 0.5),
          timestamp: now.subtract(Duration(minutes: 60 - i)),
          unit: '°C',
          setPoint: 225.0,
        ),
      );
    }

    // Generate pressure data points
    for (int i = 0; i < 60; i++) {
      points.add(
        ProcessDataPoint(
          parameter: 'pressure',
          value: 1.0 + (i * 0.01),
          timestamp: now.subtract(Duration(minutes: 60 - i)),
          unit: 'Torr',
          setPoint: 1.2,
        ),
      );
    }

    return points;
  }

  ProcessExecution? getActiveProcess() {
    return getMockProcesses().firstWhere(
      (process) => process.status == ProcessStatus.running,
      orElse: () => getMockProcesses().first,
    );
  }

  List<ProcessExecution> getRecentProcesses() {
    return getMockProcesses();
  }
}
