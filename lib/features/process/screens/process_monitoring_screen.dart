import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/process_provider.dart';
import '../models/process_execution.dart';
import '../models/process_data_point.dart';
import '../../../core/config/route_config.dart';
import 'package:fl_chart/fl_chart.dart';

class ProcessMonitoringScreen extends StatelessWidget {
  final String? processId;

  const ProcessMonitoringScreen({Key? key, this.processId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<ProcessProvider>(
      builder: (context, provider, child) {
        final process = processId != null
            ? provider.getMockProcesses().firstWhere(
                (p) => p.id == processId,
                orElse: () => provider.getActiveProcess()!,
              )
            : provider.getActiveProcess()!;

        if (process.status == ProcessStatus.completed) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Navigator.pushReplacementNamed(
              context,
              RouteConfig.experimentDetailsRoute,
              arguments: process.id,
            );
          });
        }

        return Scaffold(
          appBar: AppBar(
            title: Text('Process Monitoring'),
            actions: [
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
                icon: Icon(Icons.pause),
                onPressed: () {
                  // TODO: Implement pause
                },
              ),
              IconButton(
                icon: Icon(Icons.stop),
                onPressed: () {
                  // TODO: Implement stop
                },
              ),
            ],
          ),
          body: Column(
            children: [
              _buildStatusBar(context, process),
              Expanded(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildParameterCards(context, process),
                        SizedBox(height: 24),
                        _buildParameterCharts(context, process),
                        SizedBox(height: 24),
                        _buildCurrentStep(context, process),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatusBar(BuildContext context, ProcessExecution process) {
    return Container(
      color: _getStatusColor(process.status).withOpacity(0.1),
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Icon(
            _getStatusIcon(process.status),
            color: _getStatusColor(process.status),
          ),
          SizedBox(width: 8),
          Text(
            process.status.toString().split('.').last,
            style: TextStyle(
              color: _getStatusColor(process.status),
              fontWeight: FontWeight.bold,
            ),
          ),
          Spacer(),
          Text(
            'Duration: ${process.duration.toString().split('.').first}',
            style: TextStyle(
              color: Colors.grey[700],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildParameterCards(BuildContext context, ProcessExecution process) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      childAspectRatio: 1.5,
      children: process.parameters.entries.map((entry) {
        return Card(
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  entry.key,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                Spacer(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      entry.value.toString(),
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    Icon(
                      _getParameterIcon(entry.key),
                      color: Colors.grey,
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildParameterCharts(BuildContext context, ProcessExecution process) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Real-time Trends',
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

  Widget _buildCurrentStep(BuildContext context, ProcessExecution process) {
    final currentStep = process.recipe.steps[process.currentStepIndex];
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Current Step',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            SizedBox(height: 16),
            Text(
              currentStep.name,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            SizedBox(height: 8),
            Text(
              currentStep.description,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            SizedBox(height: 16),
            LinearProgressIndicator(
              value: process.progress,
              backgroundColor: Colors.grey[300],
            ),
          ],
        ),
      ),
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

  Color _getStatusColor(ProcessStatus status) {
    switch (status) {
      case ProcessStatus.running:
        return Colors.blue;
      case ProcessStatus.completed:
        return Colors.green;
      case ProcessStatus.failed:
        return Colors.red;
      case ProcessStatus.paused:
        return Colors.orange;
      case ProcessStatus.preparing:
        return Colors.purple;
      case ProcessStatus.aborted:
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(ProcessStatus status) {
    switch (status) {
      case ProcessStatus.running:
        return Icons.play_circle;
      case ProcessStatus.completed:
        return Icons.check_circle;
      case ProcessStatus.failed:
        return Icons.error;
      case ProcessStatus.paused:
        return Icons.pause_circle;
      case ProcessStatus.preparing:
        return Icons.pending;
      case ProcessStatus.aborted:
        return Icons.stop_circle;
      default:
        return Icons.circle;
    }
  }

  IconData _getParameterIcon(String parameter) {
    switch (parameter.toLowerCase()) {
      case 'temperature':
        return Icons.thermostat;
      case 'pressure':
        return Icons.speed;
      case 'flowrate':
        return Icons.waves;
      default:
        return Icons.show_chart;
    }
  }
}
