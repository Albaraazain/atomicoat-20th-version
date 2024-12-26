// lib/modules/system_operation_also_main_module/providers/component_values_provider.dart

import 'package:flutter/foundation.dart';
import '../models/system_component.dart';
import '../models/data_point.dart';
import '../../../utils/circular_buffer.dart';
import 'base_component_provider.dart';
import 'component_state_provider.dart';

typedef ComponentBuffer<T> = CircularBuffer<T>;

class ComponentValuesProvider extends BaseComponentProvider {
  ComponentStateProvider? _stateProvider;
  final Map<String, Map<String, ComponentBuffer<DataPoint>>> _componentValues = {};

  // Configuration
  static const int MAX_DATA_POINTS = 1000;

  // Provider Management
  void updateStateProvider(ComponentStateProvider stateProvider) {
    _stateProvider = stateProvider;
  }

  // Value Management
  Future<void> updateComponentCurrentValues(
    String componentId,
    Map<String, double> newValues,
    {String? userId}
  ) async {
    await safeUpdateComponent(componentId, () async {
      final component = componentsMap[componentId];
      if (component != null) {
        component.updateCurrentValues(newValues);
        await repository.update(componentId, component, userId: userId);

        // Update state if available
        if (_stateProvider != null) {
          await _stateProvider!.updateComponentState(
            componentId,
            parameterUpdates: newValues,
          );
        }
      }
    });
  }

  Future<void> updateComponentSetValues(
    String componentId,
    Map<String, double> newSetValues,
    {String? userId}
  ) async {
    await safeUpdateComponent(componentId, () async {
      final component = componentsMap[componentId];
      if (component != null) {
        component.updateSetValues(newSetValues);
        await repository.update(componentId, component, userId: userId);
      }
    });
  }

  Future<void> updateMinMaxValues(
    String componentId,
    {Map<String, double>? minValues, Map<String, double>? maxValues, String? userId}
  ) async {
    await safeUpdateComponent(componentId, () async {
      final component = componentsMap[componentId];
      if (component != null) {
        if (minValues != null) component.updateMinValues(minValues);
        if (maxValues != null) component.updateMaxValues(maxValues);
        await repository.update(componentId, component, userId: userId);
      }
    });
  }

  // Data Point Management
  Future<void> addParameterDataPoint(
    String componentId,
    String parameter,
    DataPoint dataPoint,
    {int maxDataPoints = MAX_DATA_POINTS}
  ) async {
    if (!validateComponentOperation(componentId, 'add parameter data point')) return;

    if (!_componentValues.containsKey(componentId)) {
      _componentValues[componentId] = {};
    }

    if (!_componentValues[componentId]!.containsKey(parameter)) {
      _componentValues[componentId]![parameter] = ComponentBuffer<DataPoint>(maxDataPoints);
    }

    _componentValues[componentId]![parameter]!.add(dataPoint);
    notifyListeners();
  }

  Future<void> updateParameterValue(
    String componentId,
    String parameter,
    double value,
    {String? userId}
  ) async {
    await safeUpdateComponent(componentId, () async {
      final component = componentsMap[componentId];
      if (component != null) {
        component.updateCurrentValues({parameter: value});

        await addParameterDataPoint(
          componentId,
          parameter,
          DataPoint(timestamp: DateTime.now(), value: value),
        );

        await repository.update(componentId, component, userId: userId);
      }
    });
  }

  // Data Retrieval
  List<DataPoint> getParameterHistory(String componentId, String parameter) {
    if (!_componentValues.containsKey(componentId) ||
        !_componentValues[componentId]!.containsKey(parameter)) {
      return [];
    }
    return _componentValues[componentId]![parameter]!.toList();
  }

  Map<String, List<DataPoint>> getAllParameterHistory(String componentId) {
    if (!_componentValues.containsKey(componentId)) {
      return {};
    }

    return Map.fromEntries(
      _componentValues[componentId]!.entries.map(
        (entry) => MapEntry(entry.key, entry.value.toList())
      )
    );
  }

  // Buffer Management
  void clearParameterHistory(String componentId, String parameter) {
    if (_componentValues.containsKey(componentId) &&
        _componentValues[componentId]!.containsKey(parameter)) {
      _componentValues[componentId]![parameter] = ComponentBuffer<DataPoint>(MAX_DATA_POINTS);
      notifyListeners();
    }
  }

  void clearAllHistory(String componentId) {
    _componentValues.remove(componentId);
    notifyListeners();
  }

  // Validation Methods
  bool hasParameter(String componentId, String parameter) {
    final component = componentsMap[componentId];
    return component?.currentValues.containsKey(parameter) ?? false;
  }

  bool isValueInRange(String componentId, String parameter, double value) {
    final component = componentsMap[componentId];
    if (component == null) return false;

    final min = component.minValues[parameter];
    final max = component.maxValues[parameter];

    if (min != null && value < min) return false;
    if (max != null && value > max) return false;
    return true;
  }

  // Value Analysis
  Map<String, dynamic> getParameterStatistics(String componentId, String parameter) {
    final history = getParameterHistory(componentId, parameter);
    if (history.isEmpty) {
      return {
        'min': null,
        'max': null,
        'average': null,
        'count': 0,
      };
    }

    final values = history.map((dp) => dp.value).toList();
    return {
      'min': values.reduce((a, b) => a < b ? a : b),
      'max': values.reduce((a, b) => a > b ? a : b),
      'average': values.reduce((a, b) => a + b) / values.length,
      'count': values.length,
    };
  }

  // Batch Operations
  Future<void> batchUpdateValues(
    String componentId,
    Map<String, double> updates,
    {String? userId}
  ) async {
    if (!validateComponentValues(updates, componentId)) {
      throw ArgumentError('Invalid values provided for component $componentId');
    }

    await safeUpdateComponent(componentId, () async {
      final component = componentsMap[componentId];
      if (component != null) {
        component.updateCurrentValues(updates);

        final timestamp = DateTime.now();
        for (var entry in updates.entries) {
          await addParameterDataPoint(
            componentId,
            entry.key,
            DataPoint(timestamp: timestamp, value: entry.value),
          );
        }

        await repository.update(componentId, component, userId: userId);
      }
    });
  }

  // Cleanup
  @override
  void dispose() {
    _componentValues.clear();
    super.dispose();
  }
}