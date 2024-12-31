import 'dart:math';
import 'package:flutter/foundation.dart';
import '../models/machine_component.dart';

class MachineMonitoringProvider extends ChangeNotifier {
  final Map<String, MachineComponent> _components = {};
  bool _isMonitoring = false;

  List<MachineComponent> get components => _components.values.toList();
  bool get isMonitoring => _isMonitoring;

  MachineComponent? getComponentByName(String name) {
    return _components[name];
  }

  // Initialize monitoring with mock data for now
  void initializeMonitoring() {
    if (_isMonitoring) return;

    _isMonitoring = true;
    _initializeMockComponents();
    notifyListeners();

    // In a real implementation, this would:
    // 1. Connect to the machine's monitoring system
    // 2. Start receiving real-time updates
    // 3. Update component states based on actual readings
  }

  void stopMonitoring() {
    _isMonitoring = false;
    _components.clear();
    notifyListeners();
  }

  // Update a component's parameter value
  void updateComponentParameter(String componentName, String parameter, double value) {
    final component = _components[componentName];
    if (component != null) {
      _components[componentName] = component.updateParameterValue(parameter, value);
      notifyListeners();
    }
  }

  // Update a component's set value
  void updateComponentSetValue(String componentName, String parameter, double value) {
    final component = _components[componentName];
    if (component != null) {
      _components[componentName] = component.updateSetValue(parameter, value);
      notifyListeners();
    }
  }

  // Mock data initialization for development
  void _initializeMockComponents() {
    final now = DateTime.now();
    final random = Random();

    List<DataPoint> generateDataPoints(double baseValue) {
      return List.generate(50, (i) {
        return DataPoint(
          now.subtract(Duration(minutes: 50 - i)),
          baseValue + random.nextDouble() * 2 - 1,
        );
      });
    }

    _components.addAll({
      'Nitrogen Generator': MachineComponent(
        name: 'Nitrogen Generator',
        parameterHistory: {
          'flow_rate': generateDataPoints(10.0),
        },
        setValues: {'flow_rate': 10.0},
        isActivated: true,
      ),
      'MFC': MachineComponent(
        name: 'MFC',
        parameterHistory: {
          'flow_rate': generateDataPoints(5.0),
        },
        setValues: {'flow_rate': 5.0},
        isActivated: true,
      ),
      'Reaction Chamber': MachineComponent(
        name: 'Reaction Chamber',
        parameterHistory: {
          'temperature': generateDataPoints(250.0),
          'pressure': generateDataPoints(1.2),
        },
        setValues: {
          'temperature': 250.0,
          'pressure': 1.2,
        },
        isActivated: true,
      ),
      'Backline Heater': MachineComponent(
        name: 'Backline Heater',
        parameterHistory: {
          'temperature': generateDataPoints(180.0),
        },
        setValues: {'temperature': 180.0},
        isActivated: true,
      ),
      'Frontline Heater': MachineComponent(
        name: 'Frontline Heater',
        parameterHistory: {
          'temperature': generateDataPoints(200.0),
        },
        setValues: {'temperature': 200.0},
        isActivated: true,
      ),
    });
  }
}