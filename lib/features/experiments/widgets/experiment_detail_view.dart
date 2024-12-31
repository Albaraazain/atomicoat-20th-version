// lib/features/experiments/widgets/experiment_detail_view.dart

import 'package:flutter/material.dart';
import '../models/experiment.dart';
import 'parameter_trend_chart.dart';
import 'process_timeline.dart';

class ExperimentDetailView extends StatefulWidget {
  final String experimentId;

  ExperimentDetailView({required this.experimentId});

  @override
  _ExperimentDetailViewState createState() => _ExperimentDetailViewState();
}

class _ExperimentDetailViewState extends State<ExperimentDetailView>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
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