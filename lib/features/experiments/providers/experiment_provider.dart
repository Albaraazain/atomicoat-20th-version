import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import '../models/experiment.dart';
import '../models/experiment_metadata.dart';
import '../models/experiment_result.dart';
import '../../../features/recipes/models/recipe.dart';
import '../../../features/process/models/process_data_point.dart';
import '../../../features/process/models/process_execution.dart';

class ExperimentProvider with ChangeNotifier {
  List<Experiment> getMockExperiments() {
    return [
      Experiment(
        id: 'exp_1',
        machineId: 'machine_1',
        recipe: Recipe.mock(),
        startTime: DateTime.now().subtract(const Duration(days: 1)),
        endTime: DateTime.now().subtract(const Duration(days: 1, hours: 2)),
        operatorId: 'operator_1',
        status: ProcessStatus.completed,
        dataPoints: _generateMockDataPoints(),
        metadata: ExperimentMetadata.defaultSettings(),
        result: ExperimentResult(
          measurements: {
            'thickness': 52.3,
            'uniformity': 98.5,
            'roughness': 0.15,
          },
          parameterDeviations: {
            'temperature': [0.02, 0.03, 0.01],
            'pressure': [0.05, 0.04, 0.03],
            'flowRate': [0.01, 0.02, 0.01],
          },
          qualityMetrics: {
            'coverage': 0.95,
            'adhesion': 0.92,
            'composition': 0.88,
          },
          qualityScore: 0.92,
          observations: [
            'Excellent film uniformity',
            'Good step coverage',
            'Minimal edge effects',
          ],
          recommendations: [
            {
              'type': 'optimization',
              'parameter': 'temperature',
              'suggestion': 'Consider reducing ramp rate',
            },
          ],
        ),
        notes: 'Standard production run with excellent results',
      ),
      Experiment(
        id: 'exp_2',
        machineId: 'machine_1',
        recipe: Recipe.mock(),
        startTime: DateTime.now().subtract(const Duration(days: 2)),
        endTime: DateTime.now().subtract(const Duration(days: 2, hours: 1)),
        operatorId: 'operator_2',
        status: ProcessStatus.completed,
        dataPoints: _generateMockDataPoints(),
        metadata: ExperimentMetadata.defaultSettings(),
        result: ExperimentResult(
          measurements: {
            'thickness': 48.7,
            'uniformity': 95.2,
            'roughness': 0.22,
          },
          parameterDeviations: {
            'temperature': [0.04, 0.05, 0.03],
            'pressure': [0.08, 0.07, 0.06],
            'flowRate': [0.03, 0.04, 0.02],
          },
          qualityMetrics: {
            'coverage': 0.88,
            'adhesion': 0.85,
            'composition': 0.82,
          },
          qualityScore: 0.82,
          observations: [
            'Slightly higher roughness than target',
            'Acceptable uniformity',
            'Minor thickness variation at edges',
          ],
          recommendations: [
            {
              'type': 'maintenance',
              'component': 'gas delivery',
              'suggestion': 'Check MFC calibration',
            },
          ],
        ),
        notes: 'Process completed with minor deviations',
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

  List<Experiment> getRecentExperiments() {
    return getMockExperiments();
  }

  Experiment? getExperimentById(String id) {
    return getMockExperiments().firstWhere(
      (exp) => exp.id == id,
      orElse: () => getMockExperiments().first,
    );
  }
}
