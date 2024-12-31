import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/process_provider.dart';
import '../models/process_execution.dart';
import '../../../core/config/route_config.dart';

class ProcessListScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Processes'),
        actions: [
          IconButton(
            icon: Icon(Icons.filter_list),
            onPressed: () {
              // TODO: Implement filtering
            },
          ),
        ],
      ),
      body: Consumer<ProcessProvider>(
        builder: (context, provider, child) {
          final processes = provider.getRecentProcesses();
          return ListView.builder(
            itemCount: processes.length,
            itemBuilder: (context, index) {
              final process = processes[index];
              return _buildProcessCard(context, process);
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, RouteConfig.processMonitoringRoute);
        },
        child: Icon(Icons.play_arrow),
        tooltip: 'Start New Process',
      ),
    );
  }

  Widget _buildProcessCard(BuildContext context, ProcessExecution process) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: InkWell(
        onTap: () {
          Navigator.pushNamed(
            context,
            RouteConfig.processDetailsRoute,
            arguments: process.id,
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
                  Text(
                    process.recipe.name,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  _buildStatusChip(process.status),
                ],
              ),
              SizedBox(height: 8),
              Text(
                'Machine: ${process.machineId}',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              SizedBox(height: 4),
              Text(
                'Started: ${process.startTime.toString()}',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              if (process.endTime != null) ...[
                SizedBox(height: 4),
                Text(
                  'Ended: ${process.endTime.toString()}',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
              SizedBox(height: 8),
              LinearProgressIndicator(
                value: process.progress,
                backgroundColor: Colors.grey[300],
                valueColor: AlwaysStoppedAnimation<Color>(
                  _getStatusColor(process.status),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusChip(ProcessStatus status) {
    return Chip(
      label: Text(
        status.toString().split('.').last,
        style: TextStyle(
          color: Colors.white,
          fontSize: 12,
        ),
      ),
      backgroundColor: _getStatusColor(status),
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
}