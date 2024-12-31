import 'package:flutter/foundation.dart';

class ParameterValue {
  final DateTime timestamp;
  final double value;

  ParameterValue(this.timestamp, this.value);
}

class ComponentParameter {
  final String name;
  final String unit;
  final double minValue;
  final double maxValue;
  final double currentValue;
  final double? setValue;
  final List<ParameterValue> history;

  ComponentParameter({
    required this.name,
    required this.unit,
    required this.minValue,
    required this.maxValue,
    required this.currentValue,
    this.setValue,
    List<ParameterValue>? history,
  }) : history = history ?? [];

  ComponentParameter copyWith({
    String? name,
    String? unit,
    double? minValue,
    double? maxValue,
    double? currentValue,
    double? setValue,
    List<ParameterValue>? history,
  }) {
    return ComponentParameter(
      name: name ?? this.name,
      unit: unit ?? this.unit,
      minValue: minValue ?? this.minValue,
      maxValue: maxValue ?? this.maxValue,
      currentValue: currentValue ?? this.currentValue,
      setValue: setValue ?? this.setValue,
      history: history ?? this.history,
    );
  }

  ComponentParameter updateValue(double value) {
    final newHistory = List<ParameterValue>.from(history)
      ..add(ParameterValue(DateTime.now(), value));

    // Keep only last 50 values
    if (newHistory.length > 50) {
      newHistory.removeAt(0);
    }

    return copyWith(
      currentValue: value,
      history: newHistory,
    );
  }

  ComponentParameter updateSetValue(double? value) {
    return copyWith(setValue: value);
  }
}
