import 'package:flutter/foundation.dart';
import 'component_parameter.dart';

enum ComponentType {
  nitrogenGenerator,
  mfc,
  heater,
  chamber,
  pressureControl,
  vacuumPump,
  valve,
}

class Component {
  final String id;
  final String name;
  final ComponentType type;
  final Map<String, ComponentParameter> parameters;
  final bool isActivated;

  Component({
    required this.id,
    required this.name,
    required this.type,
    required this.parameters,
    required this.isActivated,
  });

  Component copyWith({
    String? id,
    String? name,
    ComponentType? type,
    Map<String, ComponentParameter>? parameters,
    bool? isActivated,
  }) {
    return Component(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      parameters: parameters ?? this.parameters,
      isActivated: isActivated ?? this.isActivated,
    );
  }

  // Get the primary parameter for this component type
  String? get primaryParameterName {
    switch (type) {
      case ComponentType.nitrogenGenerator:
      case ComponentType.mfc:
        return 'flow_rate';
      case ComponentType.heater:
        return 'temperature';
      case ComponentType.chamber:
      case ComponentType.pressureControl:
        return 'pressure';
      case ComponentType.vacuumPump:
        return 'power';
      case ComponentType.valve:
        return 'status';
    }
  }

  // Get the primary parameter
  ComponentParameter? get primaryParameter {
    final name = primaryParameterName;
    return name != null ? parameters[name] : null;
  }

  // Update a parameter value
  Component updateParameterValue(String parameterName, double value) {
    final parameter = parameters[parameterName];
    if (parameter == null) return this;

    final updatedParameters = Map<String, ComponentParameter>.from(parameters);
    updatedParameters[parameterName] = parameter.updateValue(value);

    return copyWith(parameters: updatedParameters);
  }

  // Update a parameter set value
  Component updateParameterSetValue(String parameterName, double? value) {
    final parameter = parameters[parameterName];
    if (parameter == null) return this;

    final updatedParameters = Map<String, ComponentParameter>.from(parameters);
    updatedParameters[parameterName] = parameter.updateSetValue(value);

    return copyWith(parameters: updatedParameters);
  }
}
