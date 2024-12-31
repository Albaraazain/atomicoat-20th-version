import 'package:flutter/foundation.dart';

class DataPoint {
  final DateTime timestamp;
  final double value;

  DataPoint(this.timestamp, this.value);
}

class MachineComponent {
  final String name;
  final Map<String, List<DataPoint>> parameterHistory;
  final Map<String, double> setValues;
  final bool isActivated;

  MachineComponent({
    required this.name,
    required this.parameterHistory,
    required this.setValues,
    required this.isActivated,
  });

  // Helper method to get the primary parameter for this component
  String? get primaryParameter {
    switch (name) {
      case 'Nitrogen Generator':
      case 'MFC':
        return 'flow_rate';
      case 'Backline Heater':
      case 'Frontline Heater':
      case 'Precursor Heater 1':
      case 'Precursor Heater 2':
        return 'temperature';
      case 'Reaction Chamber':
        return 'pressure';
      case 'Pressure Control System':
        return 'pressure';
      case 'Vacuum Pump':
        return 'power';
      case 'Valve 1':
      case 'Valve 2':
        return 'status';
      default:
        return null;
    }
  }

  // Helper method to update a parameter value
  MachineComponent updateParameterValue(String parameter, double value) {
    final updatedHistory = Map<String, List<DataPoint>>.from(parameterHistory);
    final currentHistory = updatedHistory[parameter] ?? [];

    currentHistory.add(DataPoint(DateTime.now(), value));

    // Keep only the last 50 data points
    if (currentHistory.length > 50) {
      currentHistory.removeAt(0);
    }

    updatedHistory[parameter] = currentHistory;

    return MachineComponent(
      name: name,
      parameterHistory: updatedHistory,
      setValues: setValues,
      isActivated: isActivated,
    );
  }

  // Helper method to update a parameter set value
  MachineComponent updateSetValue(String parameter, double value) {
    final updatedSetValues = Map<String, double>.from(setValues);
    updatedSetValues[parameter] = value;

    return MachineComponent(
      name: name,
      parameterHistory: parameterHistory,
      setValues: updatedSetValues,
      isActivated: isActivated,
    );
  }
}