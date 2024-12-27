import 'package:flutter/material.dart';
import '../../models/machine.dart';
import '../../../../repositories/machine_repository.dart';
import 'machine_user_management_screen.dart';

class MachineDetailsScreen extends StatefulWidget {
  final Machine machine;

  const MachineDetailsScreen({Key? key, required this.machine}) : super(key: key);

  @override
  _MachineDetailsScreenState createState() => _MachineDetailsScreenState();
}

class _MachineDetailsScreenState extends State<MachineDetailsScreen> {
  final MachineRepository _machineRepository = MachineRepository();
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Machine Details - ${widget.machine.serialNumber}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.people),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => MachineUserManagementScreen(machine: widget.machine),
                ),
              );
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildStatusCard(),
                  const SizedBox(height: 16),
                  _buildInfoCard(),
                  const SizedBox(height: 16),
                  _buildSpecificationsCard(),
                  const SizedBox(height: 16),
                  _buildMaintenanceCard(),
                ],
              ),
            ),
    );
  }

  Widget _buildStatusCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Current Status',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                _buildStatusChip(widget.machine.status),
              ],
            ),
            const SizedBox(height: 16),
            if (widget.machine.currentOperator != null) ...[
              Text('Current Operator: ${widget.machine.currentOperator}'),
              const SizedBox(height: 8),
            ],
            if (widget.machine.currentExperiment != null) ...[
              Text('Current Experiment: ${widget.machine.currentExperiment}'),
              const SizedBox(height: 8),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatusChip(MachineStatus status) {
    Color chipColor;
    switch (status) {
      case MachineStatus.running:
        chipColor = Colors.green;
        break;
      case MachineStatus.error:
        chipColor = Colors.red;
        break;
      case MachineStatus.maintenance:
        chipColor = Colors.orange;
        break;
      case MachineStatus.offline:
        chipColor = Colors.grey;
        break;
      default:
        chipColor = Colors.blue;
    }

    return Chip(
      label: Text(
        status.toString().split('.').last,
        style: const TextStyle(color: Colors.white),
      ),
      backgroundColor: chipColor,
    );
  }

  Widget _buildInfoCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Machine Information',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildInfoRow('Serial Number', widget.machine.serialNumber),
            _buildInfoRow('Model', widget.machine.model),
            _buildInfoRow('Type', widget.machine.machineType),
            _buildInfoRow('Lab', widget.machine.labName),
            _buildInfoRow('Institution', widget.machine.labInstitution),
            _buildInfoRow('Location', widget.machine.location),
            _buildInfoRow('Installation Date',
                widget.machine.installDate.toLocal().toString().split('.')[0]),
          ],
        ),
      ),
    );
  }

  Widget _buildSpecificationsCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Specifications',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ...widget.machine.specifications.entries.map(
              (entry) => _buildInfoRow(
                entry.key,
                entry.value.toString(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMaintenanceCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Maintenance',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                TextButton.icon(
                  icon: const Icon(Icons.build),
                  label: const Text('Log Maintenance'),
                  onPressed: _logMaintenance,
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildInfoRow('Last Maintenance',
                widget.machine.lastMaintenance.toLocal().toString().split('.')[0]),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }

  Future<void> _logMaintenance() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final updatedMachine = widget.machine.copyWith(
        lastMaintenance: DateTime.now(),
        status: MachineStatus.maintenance,
      );

      await _machineRepository.update(updatedMachine.id, updatedMachine);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Maintenance logged successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error logging maintenance: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}