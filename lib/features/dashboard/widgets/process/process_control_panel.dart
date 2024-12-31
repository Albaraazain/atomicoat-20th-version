// lib/features/dashboard/widgets/process/process_control_panel.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/process_provider.dart';
import '../../providers/machine_provider.dart';
import '../../models/process_status.dart';
import '../../models/safety_interlock.dart';

class ProcessControlPanel extends StatelessWidget {
  // We'll use callbacks for process control to maintain flexibility
  final VoidCallback? onPause;
  final VoidCallback? onResume;
  final VoidCallback? onAbort;

  const ProcessControlPanel({
    this.onPause,
    this.onResume,
    this.onAbort,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer2<ProcessProvider, MachineProvider>(
      builder: (context, processProvider, machineProvider, _) {
        return Container(
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Color(0xFF2A2A2A),
            border: Border(
              top: BorderSide(color: Colors.white24),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildStatusSection(processProvider),
              SizedBox(height: 16),
              _buildControlButtons(
                context,
                processProvider,
                machineProvider,
              ),
              SizedBox(height: 16),
              _buildSafetyInterlocks(machineProvider),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatusSection(ProcessProvider processProvider) {
    // The status section shows current process state and any active warnings
    final status = processProvider.processStatus;
    final statusColor = _getStatusColor(status);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: statusColor,
                shape: BoxShape.circle,
              ),
            ),
            SizedBox(width: 8),
            Text(
              'Process Status: ${status.toString().split('.').last}',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        if (processProvider.activeWarnings.isNotEmpty)
          Padding(
            padding: EdgeInsets.only(top: 8),
            child: Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.2),
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: Colors.orange),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: processProvider.activeWarnings.map((warning) {
                  return Row(
                    children: [
                      Icon(Icons.warning_amber,
                          color: Colors.orange, size: 16),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          warning.message,
                          style: TextStyle(color: Colors.orange),
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildControlButtons(
    BuildContext context,
    ProcessProvider processProvider,
    MachineProvider machineProvider,
  ) {
    // Control buttons adapt based on process state and safety conditions
    final status = processProvider.processStatus;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Start/Resume Button
        if (status == ProcessStatus.ready || status == ProcessStatus.paused)
          _buildControlButton(
            icon: status == ProcessStatus.ready
                ? Icons.play_arrow
                : Icons.replay,
            label: status == ProcessStatus.ready ? 'Start' : 'Resume',
            color: Colors.green,
            onPressed: _canStartProcess(machineProvider)
                ? () => _handleStart(context, processProvider)
                : null,
          ),

        SizedBox(width: 16),

        // Pause Button
        if (status == ProcessStatus.running)
          _buildControlButton(
            icon: Icons.pause,
            label: 'Pause',
            color: Colors.orange,
            onPressed: _canPauseProcess(processProvider)
                ? onPause
                : null,
          ),

        SizedBox(width: 16),

        // Abort Button
        if (status != ProcessStatus.completed &&
            status != ProcessStatus.aborted)
          _buildControlButton(
            icon: Icons.stop,
            label: 'Abort',
            color: Colors.red,
            onPressed: () => _showAbortConfirmation(context),
          ),
      ],
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required String label,
    required Color color,
    VoidCallback? onPressed,
  }) {
    final isEnabled = onPressed != null;

    return ElevatedButton.icon(
      icon: Icon(icon),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: isEnabled ? color : Colors.grey,
        padding: EdgeInsets.symmetric(
          horizontal: 24,
          vertical: 16,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      onPressed: onPressed,
    );
  }

  Widget _buildSafetyInterlocks(MachineProvider machineProvider) {
    // Display active safety interlocks that prevent process execution
    final activeInterlocks = machineProvider.activeInterlocks;

    if (activeInterlocks.isEmpty) return SizedBox.shrink();

    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.red.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Safety Interlocks Active',
            style: TextStyle(
              color: Colors.red,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8),
          ...activeInterlocks.map((interlock) {
            return Padding(
              padding: EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  Icon(Icons.lock, color: Colors.red, size: 16),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      interlock.message,
                      style: TextStyle(color: Colors.red),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Future<void> _showAbortConfirmation(BuildContext context) async {
    // Show a confirmation dialog before aborting the process
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Confirm Process Abort'),
        content: Text(
          'Are you sure you want to abort the current process? '
          'This action cannot be undone and may affect the quality '
          'of the deposition.',
        ),
        actions: [
          TextButton(
            child: Text('Cancel'),
            onPressed: () => Navigator.of(context).pop(false),
          ),
          ElevatedButton(
            child: Text('Abort Process'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            onPressed: () => Navigator.of(context).pop(true),
          ),
        ],
      ),
    );

    if (confirmed == true && onAbort != null) {
      onAbort!();
    }
  }

  bool _canStartProcess(MachineProvider machineProvider) {
    // Check all safety conditions before allowing process start
    if (machineProvider.activeInterlocks.isNotEmpty) return false;
    if (!machineProvider.isCalibrated) return false;
    if (!machineProvider.areComponentsReady) return false;
    return true;
  }

  bool _canPauseProcess(ProcessProvider processProvider) {
    // Some steps might not allow pausing
    return processProvider.currentStep?.allowsPause ?? false;
  }

  Color _getStatusColor(ProcessStatus status) {
    switch (status) {
      case ProcessStatus.ready:
        return Colors.blue;
      case ProcessStatus.running:
        return Colors.green;
      case ProcessStatus.paused:
        return Colors.orange;
      case ProcessStatus.completed:
        return Colors.green;
      case ProcessStatus.aborted:
        return Colors.red;
      case ProcessStatus.error:
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}




// This ProcessControlPanel implements several critical features for safe process control:

// Status Monitoring

// Clear indication of current process state
// Active warning display
// Safety interlock status


// Adaptive Controls

// Context-aware button availability
// Clear visual feedback on available actions
// Confirmation for critical operations


// Safety Features

// Interlock system integration
// Safety checks before process start
// Clear warning messages
// Emergency abort capability






