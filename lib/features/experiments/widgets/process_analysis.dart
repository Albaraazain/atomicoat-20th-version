// lib/features/dashboard/widgets/experiment/process_analysis.dart

class ProcessAnalysis extends StatelessWidget {
  final Experiment experiment;

  const ProcessAnalysis({
    required this.experiment,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildDeviationSummary(),
        SizedBox(height: 24),
        _buildQualityMetrics(),
        SizedBox(height: 24),
        _buildRecommendations(),
      ],
    );
  }

  Widget _buildDeviationSummary() {
    final deviations = experiment.parameterDeviations;

    if (deviations.isEmpty) {
      return _buildSuccessCard(
        'No Parameter Deviations',
        'All parameters remained within their specified ranges throughout the process.',
      );
    }

    return Card(
      color: Color(0xFF2A2A2A),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              'Parameter Deviations',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          ListView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: deviations.length,
            itemBuilder: (context, index) {
              return _buildDeviationItem(deviations[index]);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildQualityMetrics() {
    return Card(
      color: Color(0xFF2A2A2A),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Process Quality Metrics',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16),
            _buildMetricGrid(),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricGrid() {
    final metrics = experiment.calculateQualityMetrics();

    return GridView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: metrics.length,
      itemBuilder: (context, index) {
        final metric = metrics[index];
        return _buildMetricCard(metric);
      },
    );
  }
}