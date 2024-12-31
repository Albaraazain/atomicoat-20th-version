// lib/features/dashboard/widgets/tabs/history_tab.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../experiments/widgets/experiment_list_view.dart';
import '../../../experiments/screens/experiment_history_screen.dart';
import '../../../experiments/providers/experiment_provider.dart';

class HistoryTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildHeader(context),
        Expanded(
          child: _buildRecentExperiments(context),
        ),
      ],
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Recent Experiments',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          TextButton.icon(
            icon: Icon(Icons.history),
            label: Text('View All'),
            style: TextButton.styleFrom(
              foregroundColor: Colors.blue,
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ExperimentHistoryScreen(
                    machineId: 'current_machine_id', // TODO: Get from provider
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildRecentExperiments(BuildContext context) {
    // TODO: Replace with actual data from ExperimentProvider
    final recentExperiments = List.generate(5, (index) => {
      'id': 'EXP-${1000 + index}',
      'recipeName': 'TiO2 Deposition',
      'status': index % 3 == 0 ? 'Completed' : (index % 3 == 1 ? 'Failed' : 'Aborted'),
      'startTime': DateTime.now().subtract(Duration(days: index)),
      'duration': Duration(hours: 2, minutes: 30),
      'operator': 'John Doe',
    });

    return ExperimentListView(
      experiments: recentExperiments,
      isCompact: true,
      onExperimentTap: (experimentId) {
        // TODO: Navigate to experiment details
      },
      physics: AlwaysScrollableScrollPhysics(),
    );
  }
}