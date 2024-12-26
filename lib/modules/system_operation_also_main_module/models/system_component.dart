import 'package:cloud_firestore/cloud_firestore.dart';
import 'data_point.dart';
import 'package:experiment_planner/utils/circular_buffer.dart' as utils;

// Create type alias to resolve conflict
typedef ComponentBuffer<T> = utils.CircularBuffer<T>;

enum ComponentStatus { normal, warning, error, ok }

class SystemComponent {
  final String name;
  final String description;
  ComponentStatus status;
  final Map<String, double> currentValues;
  final Map<String, double> setValues;
  final List<String> errorMessages;
  final Map<String, ComponentBuffer<DataPoint>> parameterHistory;
  bool isActivated;

  DateTime? lastCheckDate;
  final Map<String, double> minValues;
  final Map<String, double> maxValues;

  static const int MAX_HISTORY_SIZE = 100;


  SystemComponent({
    required this.name,
    required this.description,
    this.status = ComponentStatus.normal,
    required Map<String, double> currentValues,
    required Map<String, double> setValues,
    List<String>? errorMessages,
    this.isActivated = false,
    this.lastCheckDate,
    Map<String, double>? minValues,
    Map<String, double>? maxValues,
  })  : currentValues = Map.from(currentValues),
        setValues = Map.from(setValues),
        errorMessages = errorMessages ?? [],
        minValues = minValues ?? {},
        maxValues = maxValues ?? {},
        parameterHistory = Map.fromEntries(
          currentValues.keys.map(
                (key) => MapEntry(key, ComponentBuffer<DataPoint>(MAX_HISTORY_SIZE)),
          ),
        );

  void updateCurrentValues(Map<String, double> values) {
    currentValues.addAll(values);
    values.forEach((parameter, value) {
      parameterHistory[parameter]?.add(
        DataPoint.reducedPrecision(
          timestamp: DateTime.now(),
          value: value,
        ),
      );
    });
  }

  void updateSetValues(Map<String, double> values) {
    setValues.addAll(values);
  }

  void addErrorMessage(String message) {
    errorMessages.add(message);
  }

  void clearErrorMessages() {
    errorMessages.clear();
  }

  void updateLastCheckDate(DateTime date) {
    lastCheckDate = date;
  }

  void updateMinValues(Map<String, double> newMinValues) {
    minValues.addAll(newMinValues);
  }

  void updateMaxValues(Map<String, double> newMaxValues) {
    maxValues.addAll(newMaxValues);
  }

  factory SystemComponent.fromJson(Map<String, dynamic> json) {
    final component = SystemComponent(
      name: json['name'] as String,
      description: json['description'] as String,
      status: ComponentStatus.values.firstWhere(
            (e) => e.toString() == 'ComponentStatus.${json['status']}',
      ),
      currentValues: Map<String, double>.from(json['currentValues']),
      setValues: Map<String, double>.from(json['setValues']),
      errorMessages: List<String>.from(json['errorMessages']),
      isActivated: json['isActivated'] as bool,
      lastCheckDate: json['lastCheckDate'] != null
          ? (json['lastCheckDate'] as Timestamp).toDate()
          : null,
      minValues: json['minValues'] != null
          ? Map<String, double>.from(json['minValues'])
          : null,
      maxValues: json['maxValues'] != null
          ? Map<String, double>.from(json['maxValues'])
          : null,
    );

    if (json['parameterHistory'] != null) {
      (json['parameterHistory'] as Map<String, dynamic>).forEach((key, value) {
        final buffer = ComponentBuffer<DataPoint>(MAX_HISTORY_SIZE);
        final dataPoints = (value as List)
            .map((dp) => DataPoint.fromJson(dp as Map<String, dynamic>))
            .take(MAX_HISTORY_SIZE)
            .toList();
        buffer.addAll(dataPoints);
        component.parameterHistory[key] = buffer;
      });
    }

    return component;
  }

  Map<String, dynamic> toJson() => {
    'name': name,
    'description': description,
    'status': status.toString().split('.').last,
    'currentValues': currentValues,
    'setValues': setValues,
    'errorMessages': errorMessages,
    'isActivated': isActivated,
    'lastCheckDate':
    lastCheckDate != null ? Timestamp.fromDate(lastCheckDate!) : null,
    'minValues': minValues,
    'maxValues': maxValues,
    'parameterHistory': parameterHistory.map(
          (key, value) => MapEntry(
        key,
        value.toList().map((dp) => dp.toJson()).toList(),
      ),
    ),
  };

  String get type => name;
  DateTime get lastMaintenanceDate => lastCheckDate!;
  String get id => name;
}