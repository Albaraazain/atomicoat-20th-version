class ExperimentMetadata {
  final Map<String, double> parameterTolerances;
  final double qualityThreshold;
  final Map<String, String> parameterUnits;
  final Map<String, dynamic> substrateInfo;
  final Map<String, dynamic> environmentalConditions;
  final Map<String, dynamic> equipmentSettings;

  ExperimentMetadata({
    required this.parameterTolerances,
    required this.qualityThreshold,
    required this.parameterUnits,
    required this.substrateInfo,
    required this.environmentalConditions,
    required this.equipmentSettings,
  });

  bool isParameterWithinTolerance(String parameter, double value, double setPoint) {
    final tolerance = parameterTolerances[parameter] ?? 0.05; // Default 5% tolerance
    final deviation = (value - setPoint).abs();
    return deviation <= (setPoint * tolerance);
  }

  String getUnit(String parameter) => parameterUnits[parameter] ?? '';

  Map<String, dynamic> toMap() {
    return {
      'parameterTolerances': parameterTolerances,
      'qualityThreshold': qualityThreshold,
      'parameterUnits': parameterUnits,
      'substrateInfo': substrateInfo,
      'environmentalConditions': environmentalConditions,
      'equipmentSettings': equipmentSettings,
    };
  }

  factory ExperimentMetadata.fromMap(Map<String, dynamic> map) {
    return ExperimentMetadata(
      parameterTolerances: Map<String, double>.from(map['parameterTolerances']),
      qualityThreshold: map['qualityThreshold'].toDouble(),
      parameterUnits: Map<String, String>.from(map['parameterUnits']),
      substrateInfo: Map<String, dynamic>.from(map['substrateInfo']),
      environmentalConditions: Map<String, dynamic>.from(map['environmentalConditions']),
      equipmentSettings: Map<String, dynamic>.from(map['equipmentSettings']),
    );
  }

  factory ExperimentMetadata.defaultSettings() {
    return ExperimentMetadata(
      parameterTolerances: {
        'temperature': 0.05,
        'pressure': 0.10,
        'flowRate': 0.05,
      },
      qualityThreshold: 0.85,
      parameterUnits: {
        'temperature': '°C',
        'pressure': 'Torr',
        'flowRate': 'sccm',
      },
      substrateInfo: {
        'type': 'Silicon Wafer',
        'size': '200mm',
        'orientation': '(100)',
      },
      environmentalConditions: {
        'roomTemperature': 20.0,
        'humidity': 45.0,
      },
      equipmentSettings: {
        'chamberVolume': 5.0,
        'pumpingSpeed': 250.0,
      },
    );
  }
}
