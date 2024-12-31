import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/experiment_provider.dart';
import '../models/experiment.dart';
import '../../../core/config/route_config.dart';
import 'package:fl_chart/fl_chart.dart';

class ExperimentDetailsScreen extends StatelessWidget {
  final String experimentId;

  const ExperimentDetailsScreen({Key? key, required this.experimentId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<ExperimentProvider>(
      builder: (context, provider, child) {
        final experiment = provider.getExperimentById(experimentId)!;
        final result = experiment.result;

        return Scaffold(
          appBar: AppBar(
            title: Text('Experiment Details'),
            actions: [
              IconButton(
                icon: Icon(Icons.share),
                onPressed: () {
                  // TODO: Implement sharing
                },
              ),
              PopupMenuButton<String>(
                onSelected: (value) {
                  switch (value) {
                    case 'process':
                      Navigator.pushNamed(
                        context,
                        RouteConfig.processDetailsRoute,
                        arguments: experiment.id,
                      );
                      break;
                    case 'recipe':
                      Navigator.pushNamed(
                        context,
                        RouteConfig.recipeDetailsRoute,
                        arguments: experiment.recipe.id,
                      );
                      break;
                  }
                },
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: 'process',
                    child: ListTile(
                      leading: Icon(Icons.play_circle_outline),
                      title: Text('View Process'),
                    ),
                  ),
                  PopupMenuItem(
                    value: 'recipe',
                    child: ListTile(
                      leading: Icon(Icons.receipt_long),
                      title: Text('View Recipe'),
                    ),
                  ),
                ],
              ),
            ],
          ),
          body: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(context, experiment),
                  if (result != null) ...[
                    SizedBox(height: 24),
                    _buildQualityMetrics(context, result),
                    SizedBox(height: 24),
                    _buildParameterDeviations(context, result),
                    SizedBox(height: 24),
                    _buildObservations(context, result),
                    SizedBox(height: 24),
                    _buildRecommendations(context, result),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context, Experiment experiment) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              experiment.recipe.name,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            SizedBox(height: 8),
            Text(
              'Status: ${experiment.status.toString().split('.').last}',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            SizedBox(height: 4),
            Text(
              'Machine: ${experiment.machineId}',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            SizedBox(height: 4),
            Text(
              'Operator: ${experiment.operatorId}',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            SizedBox(height: 4),
            Text(
              'Duration: ${experiment.duration.toString().split('.').first}',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQualityMetrics(BuildContext context, ExperimentResult result) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quality Metrics',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        SizedBox(height: 16),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          childAspectRatio: 1.5,
          children: result.qualityMetrics.entries.map((entry) {
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
                    Text(
                      '${(entry.value * 100).toStringAsFixed(1)}%',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildParameterDeviations(BuildContext context, ExperimentResult result) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Parameter Deviations',
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
              lineBarsData: result.parameterDeviations.entries.map((entry) {
                return LineChartBarData(
                  spots: entry.value.asMap().entries.map((point) {
                    return FlSpot(point.key.toDouble(), point.value);
                  }).toList(),
                  isCurved: true,
                  color: _getParameterColor(entry.key),
                  barWidth: 2,
                  dotData: FlDotData(show: false),
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildObservations(BuildContext context, ExperimentResult result) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Observations',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        SizedBox(height: 16),
        Card(
          child: ListView.separated(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: result.observations.length,
            separatorBuilder: (context, index) => Divider(),
            itemBuilder: (context, index) {
              return ListTile(
                leading: Icon(Icons.lens, size: 12),
                title: Text(result.observations[index]),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildRecommendations(BuildContext context, ExperimentResult result) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Recommendations',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        SizedBox(height: 16),
        Card(
          child: ListView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: result.recommendations.length,
            itemBuilder: (context, index) {
              final recommendation = result.recommendations[index];
              return ListTile(
                leading: Icon(_getRecommendationIcon(recommendation['type'])),
                title: Text(recommendation['suggestion']),
                subtitle: Text(recommendation['parameter'] ?? ''),
              );
            },
          ),
        ),
      ],
    );
  }

  Color _getParameterColor(String parameter) {
    switch (parameter.toLowerCase()) {
      case 'temperature':
        return Colors.red;
      case 'pressure':
        return Colors.blue;
      case 'flowrate':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  IconData _getRecommendationIcon(String? type) {
    switch (type?.toLowerCase()) {
      case 'optimization':
        return Icons.trending_up;
      case 'maintenance':
        return Icons.build;
      case 'calibration':
        return Icons.tune;
      default:
        return Icons.lightbulb;
    }
  }
}