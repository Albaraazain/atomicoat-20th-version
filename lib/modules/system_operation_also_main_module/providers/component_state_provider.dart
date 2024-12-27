// lib/modules/system_operation_also_main_module/providers/component_state_provider.dart

import '../models/system_component.dart';
import '../models/data_point.dart';
import 'base_component_provider.dart';

class ComponentStateProvider extends BaseComponentProvider {
  final Map<String, ComponentState> _componentStates = {};

  // Getter for component states
  Map<String, ComponentState> get componentStates => Map.unmodifiable(_componentStates);

  // Initialize component state
  void initializeComponentState(String componentId) {
    if (!validateComponentOperation(componentId, 'initialize state')) return;

    final component = componentsMap[componentId];
    if (component != null) {
      _componentStates[componentId] = ComponentState(
        lastUpdateTime: DateTime.now(),
        isRunning: false,
        currentMode: ComponentMode.idle,
        errorState: null,
        dataBuffer: Map.fromEntries(
          component.currentValues.keys.map(
            (parameter) => MapEntry(parameter, ComponentBuffer<DataPoint>(1000))
          )
        ),
      );
      notifyListeners();
    }
  }

  // Update component state
  Future<void> updateComponentState(String componentId, {
    bool? isRunning,
    ComponentMode? mode,
    ErrorState? errorState,
    Map<String, double>? parameterUpdates,
  }) async {
    if (!validateComponentOperation(componentId, 'update state')) return;

    final state = _componentStates[componentId];
    final component = componentsMap[componentId];

    if (state != null && component != null) {
      // Update state properties
      if (isRunning != null) state.isRunning = isRunning;
      if (mode != null) state.currentMode = mode;
      if (errorState != null) state.errorState = errorState;

      // Update parameters and add to history
      if (parameterUpdates != null) {
        for (var entry in parameterUpdates.entries) {
          final dataPoint = DataPoint(
            timestamp: DateTime.now(),
            value: entry.value,
          );

          state.dataBuffer[entry.key]?.add(dataPoint);
          component.updateCurrentValues({entry.key: entry.value});
        }
      }

      state.lastUpdateTime = DateTime.now();
      notifyListeners();
    }
  }

  // Get state history for a parameter
  List<DataPoint> getParameterHistory(String componentId, String parameter) {
    final state = _componentStates[componentId];
    if (state?.dataBuffer[parameter] == null) return [];
    return state!.dataBuffer[parameter]!.toList();
  }

  // Clear component state
  void clearComponentState(String componentId) {
    _componentStates.remove(componentId);
    notifyListeners();
  }

  // Reset all states
  void resetAllStates() {
    _componentStates.clear();
    notifyListeners();
  }

  // Check if component is in error state
  bool isComponentInError(String componentId) {
    return _componentStates[componentId]?.errorState != null;
  }

  // Get all components in specific mode
  List<String> getComponentsInMode(ComponentMode mode) {
    return _componentStates.entries
        .where((entry) => entry.value.currentMode == mode)
        .map((entry) => entry.key)
        .toList();
  }
}

// Component State Model
class ComponentState {
  DateTime lastUpdateTime;
  bool isRunning;
  ComponentMode currentMode;
  ErrorState? errorState;
  final Map<String, ComponentBuffer<DataPoint>> dataBuffer;

  ComponentState({
    required this.lastUpdateTime,
    required this.isRunning,
    required this.currentMode,
    this.errorState,
    required this.dataBuffer,
  });
}

// Component Modes
enum ComponentMode {
  idle,
  starting,
  running,
  stopping,
  maintenance,
  error,
}

// Error State Model
class ErrorState {
  final String code;
  final String message;
  final DateTime timestamp;
  final ErrorSeverity severity;

  ErrorState({
    required this.code,
    required this.message,
    required this.timestamp,
    required this.severity,
  });
}

enum ErrorSeverity {
  low,
  medium,
  high,
  critical,
}