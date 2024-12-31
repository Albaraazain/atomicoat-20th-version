import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/experiment_provider.dart';
import '../models/experiment.dart';
import '../../../core/config/route_config.dart';

class ExperimentListScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Experiments'),
        actions: [
          IconButton(
            icon: Icon(Icons.filter_list),
            onPressed: () {
              // TODO: Implement filtering
            },
          ),
          IconButton(
            icon: Icon(Icons.analytics),
            onPressed: () {
              // TODO: Show analytics dashboard
            },
          ),
        ],
      ),
      body: Consumer<ExperimentProvider>(
        builder: (context, provider, child) {
          final experiments = provider.getRecentExperiments();
          return ListView.builder(
            itemCount: experiments.length,
            itemBuilder: (context, index) {
              final experiment = experiments[index];
              return _buildExperimentCard(context, experiment);
            },
          );
        },
      ),
    );
  }

  Widget _buildExperimentCard(BuildContext context, Experiment experiment) {
    final result = experiment.result;
    final qualityScore = result?.qualityScore ?? 0.0;
    final qualityColor = _getQualityColor(qualityScore);

    return Card(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: InkWell(
        onTap: () {
          Navigator.pushNamed(
            context,
            RouteConfig.experimentDetailsRoute,
            arguments: experiment.id,
          );
        },
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      experiment.recipe.name,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ),
                  if (result != null) ...[
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: qualityColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            _getQualityIcon(qualityScore),
                            color: qualityColor,
                            size: 16,
                          ),
                          SizedBox(width: 4),
                          Text(
                            '${(qualityScore * 100).toStringAsFixed(1)}%',
                            style: TextStyle(
                              color: qualityColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
              SizedBox(height: 8),
              Text(
                'Machine: ${experiment.machineId}',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              SizedBox(height: 4),
              Text(
                'Date: ${experiment.startTime.toString().split('.')[0]}',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              if (result != null && result.criticalDeviations.isNotEmpty) ...[
                SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: result.criticalDeviations.map((deviation) {
                    return Chip(
                      label: Text(
                        deviation,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                        ),
                      ),
                      backgroundColor: Colors.orange,
                    );
                  }).toList(),
                ),
              ],
              SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton.icon(
                    icon: Icon(Icons.play_circle_outline),
                    label: Text('View Process'),
                    onPressed: () {
                      Navigator.pushNamed(
                        context,
                        RouteConfig.processDetailsRoute,
                        arguments: experiment.id,
                      );
                    },
                  ),
                  SizedBox(width: 8),
                  TextButton.icon(
                    icon: Icon(Icons.receipt_long),
                    label: Text('View Recipe'),
                    onPressed: () {
                      Navigator.pushNamed(
                        context,
                        RouteConfig.recipeDetailsRoute,
                        arguments: experiment.recipe.id,
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getQualityColor(double score) {
    if (score >= 0.9) return Colors.green;
    if (score >= 0.8) return Colors.lightGreen;
    if (score >= 0.7) return Colors.orange;
    return Colors.red;
  }

  IconData _getQualityIcon(double score) {
    if (score >= 0.9) return Icons.sentiment_very_satisfied;
    if (score >= 0.8) return Icons.sentiment_satisfied;
    if (score >= 0.7) return Icons.sentiment_neutral;
    return Icons.sentiment_dissatisfied;
  }
}