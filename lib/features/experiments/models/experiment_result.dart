class ExperimentResult {
  final Map<String, double> measurements;
  final Map<String, List<double>> parameterDeviations;
  final Map<String, double> qualityMetrics;
  final double qualityScore;
  final List<String> observations;
  final List<Map<String, dynamic>> recommendations;

  ExperimentResult({
    required this.measurements,
    required this.parameterDeviations,
    required this.qualityMetrics,
    required this.qualityScore,
    required this.observations,
    required this.recommendations,
  });

  bool get meetsQualityThreshold => qualityScore >= 0.85;

  List<String> get criticalDeviations {
    final critical = <String>[];
    parameterDeviations.forEach((parameter, deviations) {
      final maxDeviation = deviations.reduce((a, b) => a > b ? a : b);
      if (maxDeviation > 0.1) { // 10% deviation threshold
        critical.add('$parameter: ${(maxDeviation * 100).toStringAsFixed(1)}%');
      }
    });
    return critical;
  }

  Map<String, dynamic> toMap() {
    return {
      'measurements': measurements,
      'parameterDeviations': parameterDeviations,
      'qualityMetrics': qualityMetrics,
      'qualityScore': qualityScore,
      'observations': observations,
      'recommendations': recommendations,
    };
  }

  factory ExperimentResult.fromMap(Map<String, dynamic> map) {
    return ExperimentResult(
      measurements: Map<String, double>.from(map['measurements']),
      parameterDeviations: Map<String, List<double>>.from(
        map['parameterDeviations'].map(
          (key, value) => MapEntry(key, List<double>.from(value)),
        ),
      ),
      qualityMetrics: Map<String, double>.from(map['qualityMetrics']),
      qualityScore: map['qualityScore'].toDouble(),
      observations: List<String>.from(map['observations']),
      recommendations: List<Map<String, dynamic>>.from(map['recommendations']),
    );
  }

  factory ExperimentResult.empty() {
    return ExperimentResult(
      measurements: {},
      parameterDeviations: {},
      qualityMetrics: {},
      qualityScore: 0.0,
      observations: [],
      recommendations: [],
    );
  }

  ExperimentResult copyWith({
    Map<String, double>? measurements,
    Map<String, List<double>>? parameterDeviations,
    Map<String, double>? qualityMetrics,
    double? qualityScore,
    List<String>? observations,
    List<Map<String, dynamic>>? recommendations,
  }) {
    return ExperimentResult(
      measurements: measurements ?? this.measurements,
      parameterDeviations: parameterDeviations ?? this.parameterDeviations,
      qualityMetrics: qualityMetrics ?? this.qualityMetrics,
      qualityScore: qualityScore ?? this.qualityScore,
      observations: observations ?? this.observations,
      recommendations: recommendations ?? this.recommendations,
    );
  }
}
