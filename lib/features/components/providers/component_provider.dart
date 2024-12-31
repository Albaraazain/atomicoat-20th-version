import 'dart:math';
import 'package:flutter/foundation.dart';
import '../models/component.dart';
import '../models/component_parameter.dart';

class ComponentProvider extends ChangeNotifier {
  final Map<String, Component> _components = {};
  bool _isMonitoring = false;

  List<Component> get components => _components.values.toList();
  bool get isMonitoring => _isMonitoring;

  Component? getComponentById(String id) {
    return _components[id];
  }

  Component? getComponentByName(String name) {
    try {
      return components.firstWhere((c) => c.name == name);
    } catch (e) {
      return null;
    }
  }

  void initializeMonitoring() {
    if (_isMonitoring) return;

    // Initialize mock components first
    _initializeMockComponents();

    // Then set monitoring flag and notify
    _isMonitoring = true;
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
  void updateComponentParameter(String componentId, String parameterName, double value) {
    final component = _components[componentId];
    if (component != null) {
      _components[componentId] = component.updateParameterValue(parameterName, value);
      notifyListeners();
    }
  }

  // Update a component's parameter set value
  void updateComponentSetValue(String componentId, String parameterName, double? value) {
    final component = _components[componentId];
    if (component != null) {
      _components[componentId] = component.updateParameterSetValue(parameterName, value);
      notifyListeners();
    }
  }

  // Mock data initialization for development
  void _initializeMockComponents() {
    final now = DateTime.now();
    final random = Random();

    List<ParameterValue> generateValues(double baseValue) {
      return List.generate(50, (i) {
        final value = baseValue + sin(i * 0.2) * (random.nextDouble() * 2);
        return ParameterValue(
          now.subtract(Duration(minutes: 50 - i)),
          value,
        );
      });
    }

    ComponentParameter createParameter({
      required String name,
      required String unit,
      required double currentValue,
      required double minValue,
      required double maxValue,
      double? setValue,
    }) {
      return ComponentParameter(
        name: name,
        unit: unit,
        currentValue: currentValue,
        minValue: minValue,
        maxValue: maxValue,
        setValue: setValue,
        history: generateValues(currentValue),
      );
    }

    void addComponent({
      required String name,
      required ComponentType type,
      required Map<String, ComponentParameter> parameters,
      bool isActivated = true,
    }) {
      final component = Component(
        id: name.toLowerCase().replaceAll(' ', '_'),
        name: name,
        type: type,
        parameters: parameters,
        isActivated: isActivated,
      );
      _components[component.id] = component;
    }

    // Add mock components with more realistic values
    addComponent(
      name: 'Nitrogen Generator',
      type: ComponentType.nitrogenGenerator,
      parameters: {
        'flow_rate': createParameter(
          name: 'Flow Rate',
          unit: 'L/min',
          currentValue: 10.0,
          minValue: 0.0,
          maxValue: 20.0,
          setValue: 10.0,
        ),
      },
    );

    addComponent(
      name: 'MFC',
      type: ComponentType.mfc,
      parameters: {
        'flow_rate': createParameter(
          name: 'Flow Rate',
          unit: 'sccm',
          currentValue: 5.0,
          minValue: 0.0,
          maxValue: 10.0,
          setValue: 5.0,
        ),
      },
    );

    addComponent(
      name: 'Reaction Chamber',
      type: ComponentType.chamber,
      parameters: {
        'temperature': createParameter(
          name: 'Temperature',
          unit: '°C',
          currentValue: 250.0,
          minValue: 0.0,
          maxValue: 300.0,
          setValue: 250.0,
        ),
        'pressure': createParameter(
          name: 'Pressure',
          unit: 'Torr',
          currentValue: 1.2,
          minValue: 0.0,
          maxValue: 2.0,
          setValue: 1.2,
        ),
      },
    );

    addComponent(
      name: 'Backline Heater',
      type: ComponentType.heater,
      parameters: {
        'temperature': createParameter(
          name: 'Temperature',
          unit: '°C',
          currentValue: 180.0,
          minValue: 0.0,
          maxValue: 250.0,
          setValue: 180.0,
        ),
      },
    );

    addComponent(
      name: 'Frontline Heater',
      type: ComponentType.heater,
      parameters: {
        'temperature': createParameter(
          name: 'Temperature',
          unit: '°C',
          currentValue: 200.0,
          minValue: 0.0,
          maxValue: 250.0,
          setValue: 200.0,
        ),
      },
    );

    addComponent(
      name: 'Precursor Heater 1',
      type: ComponentType.heater,
      parameters: {
        'temperature': createParameter(
          name: 'Temperature',
          unit: '°C',
          currentValue: 150.0,
          minValue: 0.0,
          maxValue: 200.0,
          setValue: 150.0,
        ),
      },
    );

    addComponent(
      name: 'Precursor Heater 2',
      type: ComponentType.heater,
      parameters: {
        'temperature': createParameter(
          name: 'Temperature',
          unit: '°C',
          currentValue: 160.0,
          minValue: 0.0,
          maxValue: 200.0,
          setValue: 160.0,
        ),
      },
    );

    addComponent(
      name: 'Pressure Control System',
      type: ComponentType.pressureControl,
      parameters: {
        'pressure': createParameter(
          name: 'Pressure',
          unit: 'Torr',
          currentValue: 1.0,
          minValue: 0.0,
          maxValue: 2.0,
          setValue: 1.0,
        ),
      },
    );

    addComponent(
      name: 'Vacuum Pump',
      type: ComponentType.vacuumPump,
      parameters: {
        'power': createParameter(
          name: 'Power',
          unit: '%',
          currentValue: 80.0,
          minValue: 0.0,
          maxValue: 100.0,
          setValue: 80.0,
        ),
      },
    );

    addComponent(
      name: 'Valve 1',
      type: ComponentType.valve,
      parameters: {
        'status': createParameter(
          name: 'Status',
          unit: '%',
          currentValue: 100.0,
          minValue: 0.0,
          maxValue: 100.0,
          setValue: 100.0,
        ),
      },
    );

    addComponent(
      name: 'Valve 2',
      type: ComponentType.valve,
      parameters: {
        'status': createParameter(
          name: 'Status',
          unit: '%',
          currentValue: 0.0,
          minValue: 0.0,
          maxValue: 100.0,
          setValue: 0.0,
        ),
      },
    );
  }
}
