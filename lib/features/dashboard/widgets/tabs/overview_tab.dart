// lib/features/dashboard/widgets/tabs/overview_tab.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../overlays/component_control_overlay.dart';
import '../overlays/parameter_monitor_overlay.dart';
import '../overlays/flow_visualization_overlay.dart';
import '../../providers/machine_provider.dart';
import '../../providers/process_provider.dart';

class OverviewTab extends StatelessWidget {
  final OverlayType currentOverlayType;
  final Function(OverlayType) onOverlayChanged;

  const OverviewTab({
    required this.currentOverlayType,
    required this.onOverlayChanged,
  });

  @override
  Widget build(BuildContext context) {
    // We use LayoutBuilder to make our interface responsive
    return LayoutBuilder(
      builder: (context, constraints) {
        // Determine if we're on a larger screen
        final isLargeScreen = constraints.maxWidth > 600;

        return Column(
          children: [
            Expanded(
              flex: isLargeScreen ? 2 : 1,
              child: _buildMachineVisualization(context),
            ),
            if (!isLargeScreen) _buildParameterSummary(context),
            _buildQuickControls(context),
          ],
        );
      },
    );
  }

  Widget _buildMachineVisualization(BuildContext context) {
    return Card(
      margin: EdgeInsets.all(12),
      color: Color(0xFF2A2A2A),
      child: Stack(
        children: [
          // System diagram with current overlay
          _buildCurrentOverlay(),

          // Overlay selector in top-left corner
          Positioned(
            top: 12,
            left: 12,
            child: _buildOverlaySelector(context),
          ),

          // Process status indicator in top-right corner
          Positioned(
            top: 12,
            right: 12,
            child: _buildProcessStatus(context),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentOverlay() {
    switch (currentOverlayType) {
      case OverlayType.componentControl:
        return ComponentControlOverlay(
          key: ValueKey('component_control'),
          overlayId: 'machine_overview',
        );
      case OverlayType.parameterMonitor:
        return ParameterMonitorOverlay(
          key: ValueKey('parameter_monitor'),
          overlayId: 'machine_overview',
        );
      case OverlayType.flowVisualization:
        return FlowVisualizationOverlay(
          key: ValueKey('flow_visualization'),
          overlayId: 'machine_overview',
        );
    }
  }

  Widget _buildOverlaySelector(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Color(0xFF3A3A3A),
        borderRadius: BorderRadius.circular(8),
      ),
      child: PopupMenuButton<OverlayType>(
        icon: Icon(
          _getOverlayIcon(currentOverlayType),
          color: Colors.white70,
        ),
        offset: Offset(0, 40),
        color: Color(0xFF3A3A3A),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        onSelected: onOverlayChanged,
        itemBuilder: (context) => [
          _buildOverlayMenuItem(
            OverlayType.componentControl,
            'Component Control',
            Icons.touch_app,
          ),
          _buildOverlayMenuItem(
            OverlayType.parameterMonitor,
            'Parameter Monitor',
            Icons.show_chart,
          ),
          _buildOverlayMenuItem(
            OverlayType.flowVisualization,
            'Flow Visualization',
            Icons.waves,
          ),
        ],
      ),
    );
  }

  PopupMenuItem<OverlayType> _buildOverlayMenuItem(
    OverlayType type,
    String label,
    IconData icon,
  ) {
    return PopupMenuItem<OverlayType>(
      value: type,
      child: Row(
        children: [
          Icon(icon, color: Colors.white70, size: 18),
          SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(color: Colors.white70),
          ),
        ],
      ),
    );
  }

  Widget _buildProcessStatus(BuildContext context) {
    return Consumer<ProcessProvider>(
      builder: (context, provider, _) {
        if (!provider.isProcessing) return SizedBox.shrink();

        return Container(
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.green.withOpacity(0.2),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.green),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.play_circle, color: Colors.green, size: 16),
              SizedBox(width: 8),
              Text(
                'Process Running',
                style: TextStyle(color: Colors.green),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildParameterSummary(BuildContext context) {
    return Container(
      height: 120,
      margin: EdgeInsets.symmetric(horizontal: 12),
      child: Consumer<ProcessProvider>(
        builder: (context, provider, _) {
          final criticalParameters = provider.getCriticalParameters();

          return ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: criticalParameters.length,
            itemBuilder: (context, index) {
              final parameter = criticalParameters[index];
              return _buildParameterCard(parameter);
            },
          );
        },
      ),
    );
  }

  Widget _buildParameterCard(ProcessParameter parameter) {
    return Card(
      color: Color(0xFF2A2A2A),
      child: Container(
        width: 120,
        padding: EdgeInsets.all(8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              parameter.name,
              style: TextStyle(
                color: Colors.white70,
                fontSize: 12,
              ),
            ),
            SizedBox(height: 4),
            Text(
              '${parameter.value.toStringAsFixed(2)} ${parameter.unit}',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (parameter.setPoint != null) ...[
              SizedBox(height: 4),
              Text(
                'Set: ${parameter.setPoint!.toStringAsFixed(2)}',
                style: TextStyle(
                  color: Colors.white54,
                  fontSize: 12,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildQuickControls(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(12),
      child: Row(
        children: [
          Expanded(
            child: _buildQuickControlButton(
              context: context,
              icon: Icons.play_arrow,
              label: 'Start Process',
              onPressed: () => _handleStartProcess(context),
            ),
          ),
          SizedBox(width: 8),
          Expanded(
            child: _buildQuickControlButton(
              context: context,
              icon: Icons.stop,
              label: 'Stop Process',
              onPressed: () => _handleStopProcess(context),
              backgroundColor: Colors.red,
            ),
          ),
        ],
      ),
    );
  }
}


// this overview tab is a bit more complex than the others, so we'll break it down into smaller pieces
// first, we'll look at the main build method and the machine visualization
// then we'll look at the overlay selector and process status indicator
// finally, we'll look at the parameter summary and quick controls
// let's start with the main build method and the machine visualization
// the build method uses a LayoutBuilder to make the interface responsive
// it checks if the screen width is greater than 600 to determine if it's a large screen
// if it's a large screen, the machine visualization takes up 2/3 of the available space
// if it's a small screen, the parameter summary is shown below the machine visualization
// next, let's look at the overlay selector and process status indicator
// the overlay selector is a PopupMenuButton that lets the user switch between different overlays
// it shows an icon and label for each overlay type, and calls the onOverlayChanged function when an overlay is selected
// the process status indicator shows a green bar with the text "Process Running" when a process is running
// it's positioned in the top-right corner of the machine visualization
// finally, let's look at the parameter summary and quick controls
// the parameter summary shows critical process parameters in a horizontal list
// each parameter is displayed in a Card with the parameter name, value, and unit
// if a set point is available, it's also displayed below the value
// the quick controls show buttons to start and stop the process
// the start process button is green and calls the _handleStartProcess function when pressed

// the stop process button is red and calls the _handleStopProcess function when pressed
// that's the overview tab for the machine dashboard screen
// it provides an overview of the machine status, process parameters, and quick controls
// it also allows the user to switch between different overlays to view more detailed information
// next, we'll look at the process tab, which provides step-by-step visualization of recipe progress
// and parameter monitoring for ongoing processes
