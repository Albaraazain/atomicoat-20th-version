// In data_point.dart

class ProcessDataPoint {
  final String parameter;
  final double value;
  final DateTime timestamp;
  final String? unit;
  final double? setPoint;

  ProcessDataPoint({
    required this.parameter,
    required this.value,
    required this.timestamp,
    this.unit,
    this.setPoint,
  });

  double get deviation => setPoint != null ? (value - setPoint!).abs() : 0.0;
  bool get isWithinTolerance => setPoint != null ? deviation <= (setPoint! * 0.05) : true;

  Map<String, dynamic> toMap() {
    return {
      'parameter': parameter,
      'value': value,
      'timestamp': timestamp.toIso8601String(),
      'unit': unit,
      'setPoint': setPoint,
    };
  }

  factory ProcessDataPoint.fromMap(Map<String, dynamic> map) {
    return ProcessDataPoint(
      parameter: map['parameter'],
      value: map['value'].toDouble(),
      timestamp: DateTime.parse(map['timestamp']),
      unit: map['unit'],
      setPoint: map['setPoint']?.toDouble(),
    );
  }

  @override
  String toString() => 'ProcessDataPoint($parameter: $value${unit != null ? ' $unit' : ''})';
}
