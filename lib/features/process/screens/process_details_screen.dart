import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/process_provider.dart';
import '../models/process_execution.dart';
import '../models/process_data_point.dart';
import '../../../core/config/route_config.dart';
import 'package:fl_chart/fl_chart.dart';

class ProcessDetailsScreen extends StatelessWidget {
  final String processId;

  const ProcessDetailsScreen({Key? key, required this.processId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<ProcessProvider>(
      builder: (context, provider, child) {
        final process = provider.getMockProcesses().firstWhere(
          (p) => p.id == processId,
          orElse: () => provider.getMockProcesses().first,
        );

        return Scaffold(
          appBar: AppBar(
            title: Text('Process Details'),
            actions: [
              IconButton(
                icon: Icon(Icons.science),
                tooltip: 'View Experiment',
                onPressed: () {
                  Navigator.pushNamed(
                    context,
                    RouteConfig.experimentDetailsRoute,
                    arguments: process.id,
                  );
                },
              ),
              IconButton(
                icon: Icon(Icons.receipt_long),
                tooltip: 'View Recipe',
                onPressed: () {
                  Navigator.pushNamed(
                    context,
                    RouteConfig.recipeDetailsRoute,
                    arguments: process.recipe.id,
                  );
                },
              ),
              IconButton(
                icon: Icon(Icons.share),
                onPressed: () {
                  // TODO: Implement sharing
                },
              ),
            ],
          ),
          body: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(context, process),
                  SizedBox(height: 24),
                  _buildParameterCharts(context, process),
                  SizedBox(height: 24),
                  _buildStepProgress(context, process),
                  if (process.errorMessage != null) ...[
                    SizedBox(height: 24),
                    _buildErrorMessage(context, process.errorMessage!),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context, ProcessExecution process) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              process.recipe.name,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            SizedBox(height: 8),
            Text(
              'Status: ${process.status.toString().split('.').last}',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            SizedBox(height: 4),
            Text(
              'Machine: ${process.machineId}',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            SizedBox(height: 4),
            Text(
              'Operator: ${process.operatorId}',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            SizedBox(height: 8),
            LinearProgressIndicator(
              value: process.progress,
              backgroundColor: Colors.grey[300],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildParameterCharts(BuildContext context, ProcessExecution process) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Parameter Trends',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        SizedBox(height: 16),
        SizedBox(
          height: 200,
          child: LineChart(
            LineChartData(
              gridData: FlGridData(show: true),
              titlesData: FlTitlesData(show: true),
              borderData: FlBorderData(show: true),
              lineBarsData: [
                _createLineChartBarData('temperature', process.getParameterData('temperature')),
                _createLineChartBarData('pressure', process.getParameterData('pressure')),
              ],
            ),
          ),
        ),
      ],
    );
  }

  LineChartBarData _createLineChartBarData(String parameter, List<ProcessDataPoint> data) {
    return LineChartBarData(
      spots: data.asMap().entries.map((entry) {
        return FlSpot(entry.key.toDouble(), entry.value.value);
      }).toList(),
      isCurved: true,
      color: parameter == 'temperature' ? Colors.red : Colors.blue,
      barWidth: 2,
      dotData: FlDotData(show: false),
    );
  }

  Widget _buildStepProgress(BuildContext context, ProcessExecution process) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Recipe Steps',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        SizedBox(height: 16),
        ListView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          itemCount: process.recipe.steps.length,
          itemBuilder: (context, index) {
            final step = process.recipe.steps[index];
            final isCompleted = index < process.currentStepIndex;
            final isCurrent = index == process.currentStepIndex;

            return ListTile(
              leading: Icon(
                isCompleted ? Icons.check_circle : (isCurrent ? Icons.play_circle : Icons.circle_outlined),
                color: isCompleted ? Colors.green : (isCurrent ? Colors.blue : Colors.grey),
              ),
              title: Text(step.name),
              subtitle: Text(step.description),
            );
          },
        ),
      ],
    );
  }

  Widget _buildErrorMessage(BuildContext context, String message) {
    return Card(
      color: Colors.red[100],
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(Icons.error, color: Colors.red),
            SizedBox(width: 16),
            Expanded(
              child: Text(
                message,
                style: TextStyle(color: Colors.red[900]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}