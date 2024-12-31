import 'package:flutter/material.dart';
import '../../../widgets/app_drawer.dart';

class MachineListScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF1A1A1A),
      appBar: AppBar(
        backgroundColor: Color(0xFF2A2A2A),
        title: Text('ALD Machines'),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () => Navigator.pushNamed(context, '/machines/create'),
          ),
        ],
      ),
      drawer: AppDrawer(),
      body: _buildMachineList(),
    );
  }

  Widget _buildMachineList() {
    // Hardcoded machines for now
    return ListView.builder(
      padding: EdgeInsets.all(16),
      itemCount: 5,
      itemBuilder: (context, index) {
        return _buildMachineCard(
          id: 'ALD-${1000 + index}',
          name: 'ALD Machine ${index + 1}',
          status: _getRandomStatus(),
          lastMaintenance: DateTime.now().subtract(Duration(days: index * 10)),
          totalProcesses: 100 + index * 20,
          context: context,
        );
      },
    );
  }

  Widget _buildMachineCard({
    required String id,
    required String name,
    required MachineStatus status,
    required DateTime lastMaintenance,
    required int totalProcesses,
    required BuildContext context,
  }) {
    return Card(
      margin: EdgeInsets.only(bottom: 16),
      color: Color(0xFF2A2A2A),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () => Navigator.pushNamed(context, '/machines/details', arguments: id),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          id,
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  _buildStatusBadge(status),
                ],
              ),
              SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildInfoItem(
                    icon: Icons.history,
                    label: 'Last Maintenance',
                    value: '${lastMaintenance.day}/${lastMaintenance.month}/${lastMaintenance.year}',
                  ),
                  _buildInfoItem(
                    icon: Icons.analytics,
                    label: 'Total Processes',
                    value: totalProcesses.toString(),
                  ),
                  _buildActionButton(context, id),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge(MachineStatus status) {
    final colors = {
      MachineStatus.idle: Colors.grey,
      MachineStatus.processing: Colors.green,
      MachineStatus.error: Colors.red,
      MachineStatus.maintenance: Colors.orange,
    };

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: colors[status]?.withOpacity(0.2),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors[status] ?? Colors.grey),
      ),
      child: Text(
        status.toString().split('.').last.toUpperCase(),
        style: TextStyle(
          color: colors[status],
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildInfoItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Column(
      children: [
        Icon(icon, color: Colors.white54, size: 20),
        SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(color: Colors.white54, fontSize: 12),
        ),
        SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(color: Colors.white, fontSize: 14),
        ),
      ],
    );
  }

  Widget _buildActionButton(BuildContext context, String machineId) {
    return PopupMenuButton<String>(
      icon: Icon(Icons.more_vert, color: Colors.white70),
      color: Color(0xFF2A2A2A),
      onSelected: (value) {
        switch (value) {
          case 'edit':
            Navigator.pushNamed(context, '/machines/edit', arguments: machineId);
            break;
          case 'delete':
            _showDeleteConfirmation(context, machineId);
            break;
        }
      },
      itemBuilder: (context) => [
        PopupMenuItem(
          value: 'edit',
          child: Row(
            children: [
              Icon(Icons.edit, color: Colors.white70, size: 20),
              SizedBox(width: 8),
              Text('Edit', style: TextStyle(color: Colors.white)),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'delete',
          child: Row(
            children: [
              Icon(Icons.delete, color: Colors.red, size: 20),
              SizedBox(width: 8),
              Text('Delete', style: TextStyle(color: Colors.red)),
            ],
          ),
        ),
      ],
    );
  }

  void _showDeleteConfirmation(BuildContext context, String machineId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Color(0xFF2A2A2A),
        title: Text('Delete Machine', style: TextStyle(color: Colors.white)),
        content: Text(
          'Are you sure you want to delete this machine? This action cannot be undone.',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              // TODO: Implement machine deletion
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Machine deleted')),
              );
            },
            child: Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  MachineStatus _getRandomStatus() {
    final statuses = [
      MachineStatus.idle,
      MachineStatus.processing,
      MachineStatus.error,
      MachineStatus.maintenance,
    ];
    return statuses[DateTime.now().microsecond % statuses.length];
  }
}

enum MachineStatus {
  idle,
  processing,
  error,
  maintenance,
}