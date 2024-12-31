import 'package:flutter/material.dart';
import '../models/experiment.dart';

class ExperimentListView extends StatelessWidget {
  final List<Map<String, dynamic>> experiments;
  final bool isCompact;
  final Function(String) onExperimentTap;
  final ScrollPhysics? physics;
  final EdgeInsets? padding;

  const ExperimentListView({
    Key? key,
    required this.experiments,
    this.isCompact = false,
    required this.onExperimentTap,
    this.physics,
    this.padding,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: padding ?? EdgeInsets.all(16),
      physics: physics,
      itemCount: experiments.length,
      itemBuilder: (context, index) {
        final experiment = experiments[index];
        return _buildExperimentCard(
          experimentId: experiment['id'],
          recipeName: experiment['recipeName'],
          status: experiment['status'],
          startTime: experiment['startTime'],
          duration: experiment['duration'],
          operator: experiment['operator'],
        );
      },
    );
  }

  Widget _buildExperimentCard({
    required String experimentId,
    required String recipeName,
    required String status,
    required DateTime startTime,
    required Duration duration,
    required String operator,
  }) {
    final statusColors = {
      'Completed': Colors.green,
      'Failed': Colors.red,
      'Aborted': Colors.orange,
    };

    return Card(
      margin: EdgeInsets.only(bottom: 16),
      color: Color(0xFF2A2A2A),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () => onExperimentTap(experimentId),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    experimentId,
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: statusColors[status]?.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      status,
                      style: TextStyle(
                        color: statusColors[status],
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8),
              Text(
                recipeName,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                ),
              ),
              if (!isCompact) ...[
                SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.access_time, color: Colors.grey, size: 16),
                    SizedBox(width: 4),
                    Text(
                      '${startTime.toString().split('.')[0]}',
                      style: TextStyle(color: Colors.grey),
                    ),
                    SizedBox(width: 16),
                    Icon(Icons.timer, color: Colors.grey, size: 16),
                    SizedBox(width: 4),
                    Text(
                      '${duration.inHours}h ${duration.inMinutes % 60}m',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
                SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.person, color: Colors.grey, size: 16),
                    SizedBox(width: 4),
                    Text(
                      operator,
                      style: TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}