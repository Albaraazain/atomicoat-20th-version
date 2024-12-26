// lib/modules/system_operation_also_main_module/providers/base_component_provider.dart

import 'package:flutter/foundation.dart';
import '../models/system_component.dart';
import '../../../repositories/system_component_repository.dart';
import '../models/data_point.dart';
import '../../../utils/circular_buffer.dart';

abstract class BaseComponentProvider with ChangeNotifier {
  final SystemComponentRepository _repository = SystemComponentRepository();
  final Map<String, SystemComponent> _components = {};

  // Public getters
  Map<String, SystemComponent> get components => Map.unmodifiable(_components);
  List<String> get componentNames => _components.keys.toList();

  // Protected getters for child classes
  SystemComponentRepository get repository => _repository;
  Map<String, SystemComponent> get componentsMap => _components;

  // Basic component operations
  SystemComponent? getComponent(String componentId) => _components[componentId];

  void updateComponent(SystemComponent component) {
    _components[component.id] = component;
    notifyListeners();
  }

  // Validation methods
  bool validateComponentOperation(String componentId, String operation) {
    final component = _components[componentId];
    if (component == null) {
      print('Warning: Attempting to $operation non-existent component $componentId');
      return false;
    }
    return true;
  }

  bool validateComponentValues(Map<String, double> values, String componentId) {
    final component = _components[componentId];
    if (component == null) return false;

    return values.entries.every((entry) {
      final min = component.minValues[entry.key];
      final max = component.maxValues[entry.key];
      if (min != null && entry.value < min) return false;
      if (max != null && entry.value > max) return false;
      return true;
    });
  }

  // Utility methods for child classes
  Future<void> safeUpdateComponent(String componentId, Future<void> Function() updateOperation) async {
    if (!validateComponentOperation(componentId, 'update')) return;
    try {
      await updateOperation();
      notifyListeners();
    } catch (e) {
      print('Error updating component $componentId: $e');
      rethrow;
    }
  }

  // Data point management
  void addDataPoint(String componentId, String parameter, DataPoint dataPoint, CircularBuffer<DataPoint> buffer) {
    if (validateComponentOperation(componentId, 'add data point')) {
      buffer.add(dataPoint);
      notifyListeners();
    }
  }

  // Repository operations
  Future<void> saveToRepository(String componentId, {String? userId}) async {
    final component = _components[componentId];
    if (component != null) {
      await _repository.update(componentId, component, userId: userId);
    }
  }
}