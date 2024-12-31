import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/experiment_provider.dart';
import '../widgets/parameter_trend_chart.dart';
import '../widgets/process_timeline.dart';

class ExperimentDetailScreen extends StatefulWidget {
  final String experimentId;

  ExperimentDetailScreen({required this.experimentId});

  @override
  _ExperimentDetailScreenState createState() => _ExperimentDetailScreenState();
}

class _ExperimentDetailScreenState extends State<ExperimentDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadExperimentData();
  }

  Future<void> _loadExperimentData() async {
    // TODO: Load experiment data from provider
    await Future.delayed(Duration(seconds: 1)); // Simulated loading
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return _buildLoadingScreen();
    }

    return Scaffold(
      backgroundColor: Color(0xFF1A1A1A),
      appBar: AppBar(
        backgroundColor: Color(0xFF2A2A2A),
        title: Text('Experiment Details'),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: 'Overview'),
            Tab(text: 'Parameters'),
            Tab(text: 'Timeline'),
            Tab(text: 'Analysis'),
          ],
          indicatorColor: Colors.blue,
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.share),
            onPressed: _shareExperiment,
          ),
          IconButton(
            icon: Icon(Icons.download),
            onPressed: _downloadReport,
          ),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildOverviewTab(),
          _buildParametersTab(),
          _buildTimelineTab(),
          _buildAnalysisTab(),
        ],
      ),
    );
  }

  Widget _buildLoadingScreen() {
    return Scaffold(
      backgroundColor: Color(0xFF1A1A1A),
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }

  Widget _buildOverviewTab() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildExperimentInfo(),
          SizedBox(height: 24),
          _buildRecipeInfo(),
          SizedBox(height: 24),
          _buildResultsSummary(),
        ],
      ),
    );
  }

  Widget _buildExperimentInfo() {
    return Card(
      color: Color(0xFF2A2A2A),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Experiment Information',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16),
            _buildInfoRow('ID', widget.experimentId),
            _buildInfoRow('Status', 'Completed'),
            _buildInfoRow('Start Time', '2023-10-15 14:30:00'),
            _buildInfoRow('Duration', '2h 30m'),
            _buildInfoRow('Operator', 'John Doe'),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(color: Colors.grey),
          ),
          Text(
            value,
            style: TextStyle(color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildRecipeInfo() {
    return Card(
      color: Color(0xFF2A2A2A),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Recipe Details',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16),
            _buildInfoRow('Recipe Name', 'TiO2 Deposition'),
            _buildInfoRow('Version', 'v1.2'),
            _buildInfoRow('Substrate', 'Silicon Wafer'),
            _buildInfoRow('Target Thickness', '100 nm'),
            _buildInfoRow('Number of Cycles', '200'),
          ],
        ),
      ),
    );
  }

  Widget _buildResultsSummary() {
    return Card(
      color: Color(0xFF2A2A2A),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Results Summary',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16),
            _buildInfoRow('Actual Thickness', '98.5 nm'),
            _buildInfoRow('Uniformity', '±2.3%'),
            _buildInfoRow('Growth Rate', '1.02 Å/cycle'),
            _buildInfoRow('Quality Score', '95%'),
          ],
        ),
      ),
    );
  }

  Widget _buildParametersTab() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        children: [
          _buildParameterTrendChart('Temperature', Colors.orange),
          SizedBox(height: 24),
          _buildParameterTrendChart('Pressure', Colors.green),
          SizedBox(height: 24),
          _buildParameterTrendChart('Flow Rate', Colors.blue),
        ],
      ),
    );
  }

  Widget _buildParameterTrendChart(String parameter, Color color) {
    return Card(
      color: Color(0xFF2A2A2A),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              parameter,
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16),
            AspectRatio(
              aspectRatio: 16 / 9,
              child: ParameterTrendChart(
                parameter: parameter,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimelineTab() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        children: [
          Card(
            color: Color(0xFF2A2A2A),
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Process Timeline',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 16),
                  ProcessTimeline(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnalysisTab() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        children: [
          _buildQualityMetrics(),
          SizedBox(height: 24),
          _buildParameterDeviations(),
          SizedBox(height: 24),
          _buildRecommendations(),
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
              'Quality Metrics',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16),
            _buildMetricRow('Thickness Uniformity', '95%', Colors.green),
            _buildMetricRow('Growth Rate Stability', '92%', Colors.green),
            _buildMetricRow('Parameter Control', '88%', Colors.orange),
            _buildMetricRow('Process Efficiency', '90%', Colors.green),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricRow(String metric, String value, Color color) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              metric,
              style: TextStyle(color: Colors.white),
            ),
          ),
          Expanded(
            flex: 3,
            child: LinearProgressIndicator(
              value: double.parse(value.replaceAll('%', '')) / 100,
              backgroundColor: Colors.grey[800],
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
          SizedBox(width: 16),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildParameterDeviations() {
    return Card(
      color: Color(0xFF2A2A2A),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Parameter Deviations',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16),
            _buildDeviationItem(
              'Temperature',
              'Max deviation: ±2.3°C',
              'Within acceptable range',
              Colors.green,
            ),
            _buildDeviationItem(
              'Pressure',
              'Max deviation: ±0.05 Torr',
              'Minor fluctuations detected',
              Colors.orange,
            ),
            _buildDeviationItem(
              'Flow Rate',
              'Max deviation: ±1.2 sccm',
              'Within acceptable range',
              Colors.green,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDeviationItem(
    String parameter,
    String deviation,
    String description,
    Color color,
  ) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            color == Colors.green ? Icons.check_circle : Icons.info,
            color: color,
          ),
          SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  parameter,
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  deviation,
                  style: TextStyle(color: Colors.grey),
                ),
                Text(
                  description,
                  style: TextStyle(color: color),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecommendations() {
    return Card(
      color: Color(0xFF2A2A2A),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Recommendations',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16),
            _buildRecommendationItem(
              'Consider increasing purge time by 0.5s to improve uniformity',
              priority: 'Medium',
            ),
            _buildRecommendationItem(
              'Monitor pressure control system for potential maintenance',
              priority: 'Low',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecommendationItem(String text, {required String priority}) {
    final colors = {
      'High': Colors.red,
      'Medium': Colors.orange,
      'Low': Colors.blue,
    };

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: colors[priority]?.withOpacity(0.2),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              priority,
              style: TextStyle(
                color: colors[priority],
                fontSize: 12,
              ),
            ),
          ),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  void _shareExperiment() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Sharing experiment data...')),
    );
  }

  void _downloadReport() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Downloading experiment report...')),
    );
  }
}
