// lib/features/dashboard/screens/machine_dashboard_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/auth/providers/auth_provider.dart';
import '../../../features/components/providers/component_provider.dart';
import '../../../widgets/app_drawer.dart';
import 'system_overview_screen.dart';

class MachineDashboard extends StatefulWidget {
  @override
  _MachineDashboardState createState() => _MachineDashboardState();
}

class _MachineDashboardState extends State<MachineDashboard> {
  final List<_DashboardTab> _tabs = [
    _DashboardTab(Icons.dashboard_rounded, 'Overview'),
    _DashboardTab(Icons.play_circle_outline_rounded, 'Process'),
    _DashboardTab(Icons.history_rounded, 'History'),
    _DashboardTab(Icons.build_rounded, 'Maintenance'),
  ];

  int _selectedTabIndex = 0;
  OverlayType _currentOverlayType = OverlayType.componentControl;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF1A1A1A),
      appBar: _buildAppBar(),
      drawer: AppDrawer(),
      body: MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => ComponentProvider()),
        ],
        child: SafeArea(
          child: Column(
            children: [
              _buildTabBar(),
              _buildOperatorSession(),
              Expanded(
                child: _buildTabContent(),
              ),
              _buildSystemOverviewButton(),
            ],
          ),
        ),
      ),
      floatingActionButton: _buildEmergencyStop(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Color(0xFF2A2A2A),
      leading: IconButton(
        icon: Icon(Icons.menu),
        onPressed: () => Scaffold.of(context).openDrawer(),
      ),
      title: Row(
        children: [
          Text('ALD Machine'),
          SizedBox(width: 8),
          _buildMachineStatus(MachineStatus.idle),
        ],
      ),
      actions: [
        IconButton(
          icon: Icon(Icons.notifications),
          onPressed: () => _showAlerts(context),
        ),
        IconButton(
          icon: Icon(Icons.logout),
          onPressed: () => _handleSessionEnd(context),
        ),
      ],
    );
  }

  Widget _buildMachineStatus(MachineStatus status) {
    final colors = {
      MachineStatus.idle: Colors.grey,
      MachineStatus.processing: Colors.green,
      MachineStatus.error: Colors.red,
      MachineStatus.maintenance: Colors.orange,
    };

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: colors[status]?.withOpacity(0.2),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: colors[status] ?? Colors.grey),
      ),
      child: Text(
        status.toString().split('.').last.toUpperCase(),
        style: TextStyle(
          fontSize: 12,
          color: colors[status],
        ),
      ),
    );
  }

  Widget _buildOperatorSession() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: Color(0xFF2A2A2A),
      child: Row(
        children: [
          Text(
            'Current Operator: John Doe',
            style: TextStyle(color: Colors.white70),
          ),
          Spacer(),
          Text(
            'Session Time: 2:30',
            style: TextStyle(color: Colors.white70),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      decoration: BoxDecoration(
        color: Color(0xFF2A2A2A),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 4,
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: _tabs.asMap().entries.map((entry) {
          final isSelected = entry.key == _selectedTabIndex;
          return InkWell(
            onTap: () => setState(() => _selectedTabIndex = entry.key),
            child: Container(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    entry.value.icon,
                    color: isSelected ? Colors.blue : Colors.white54,
                  ),
                  SizedBox(height: 4),
                  Text(
                    entry.value.label,
                    style: TextStyle(
                      color: isSelected ? Colors.blue : Colors.white54,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildTabContent() {
    return AnimatedSwitcher(
      duration: Duration(milliseconds: 300),
      child: _getSelectedTabContent(),
    );
  }

  Widget _getSelectedTabContent() {
    switch (_selectedTabIndex) {
      case 0:
        return _buildOverviewTab();
      case 1:
        return _buildProcessTab();
      case 2:
        return _buildHistoryTab();
      case 3:
        return _buildMaintenanceTab();
      default:
        return SizedBox.shrink();
    }
  }

  Widget _buildOverviewTab() {
    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.fromLTRB(16, 24, 16, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildOverlaySelector(),
            SizedBox(height: 24),
            _buildSystemDiagramWithOverlay(),
            SizedBox(height: 24),
            _buildParameterGrid(),
          ],
        ),
      ),
    );
  }

  Widget _buildSystemDiagramWithOverlay() {
    return AspectRatio(
      aspectRatio: 16 / 9, // Adjust this ratio based on your diagram's dimensions
      child: Container(
        decoration: BoxDecoration(
          color: Color(0xFF2A2A2A),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.withOpacity(0.2)),
        ),
        child: Stack(
          children: [
            // System diagram
            Positioned.fill(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(11), // 12-1 to account for border
                child: Image.asset(
                  'assets/ald_system_diagram.png',
                  fit: BoxFit.contain,
                ),
              ),
            ),
            // Overlay content based on selected type
            Positioned.fill(
              child: _buildOverlayContent(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOverlayContent() {
    // This will be where you implement different overlays based on _currentOverlayType
    switch (_currentOverlayType) {
      case OverlayType.componentControl:
        return _buildComponentControlOverlay();
      case OverlayType.parameterMonitor:
        return _buildParameterMonitorOverlay();
      case OverlayType.flowVisualization:
        return _buildFlowVisualizationOverlay();
    }
  }

  Widget _buildComponentControlOverlay() {
    // Placeholder for component control overlay
    return Container(
      padding: EdgeInsets.all(16),
      child: Center(
        child: Text(
          'Component Control Overlay',
          style: TextStyle(color: Colors.white70),
        ),
      ),
    );
  }

  Widget _buildParameterMonitorOverlay() {
    // Placeholder for parameter monitor overlay
    return Container(
      padding: EdgeInsets.all(16),
      child: Center(
        child: Text(
          'Parameter Monitor Overlay',
          style: TextStyle(color: Colors.white70),
        ),
      ),
    );
  }

  Widget _buildFlowVisualizationOverlay() {
    // Placeholder for flow visualization overlay
    return Container(
      padding: EdgeInsets.all(16),
      child: Center(
        child: Text(
          'Flow Visualization Overlay',
          style: TextStyle(color: Colors.white70),
        ),
      ),
    );
  }

  Widget _buildParameterGrid() {
    return GridView.count(
      physics: NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      crossAxisCount: 2,
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      childAspectRatio: 1.5,
      children: [
        _buildParameterCard('Temperature', '200°C', '180-220°C'),
        _buildParameterCard('Pressure', '2.5 mTorr', '2.0-3.0 mTorr'),
        _buildParameterCard('Flow Rate', '20 sccm', '15-25 sccm'),
        _buildParameterCard('Power', '1000W', '800-1200W'),
      ],
    );
  }

  Widget _buildParameterCard(String name, String value, String range) {
    return Card(
      elevation: 4,
      color: Color(0xFF2A2A2A),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.withOpacity(0.2), width: 1),
      ),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              name,
              style: TextStyle(
                color: Colors.white70,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 28,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 4),
            Text(
              range,
              style: TextStyle(
                color: Colors.white54,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOverlaySelector() {
    return Container(
      decoration: BoxDecoration(
        color: Color(0xFF2A2A2A).withOpacity(0.7),
        borderRadius: BorderRadius.circular(12),
      ),
      padding: EdgeInsets.all(8),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildOverlayButton(
              OverlayType.componentControl,
              'Components',
              Icons.settings,
            ),
            SizedBox(width: 8),
            _buildOverlayButton(
              OverlayType.parameterMonitor,
              'Parameters',
              Icons.show_chart,
            ),
            SizedBox(width: 8),
            _buildOverlayButton(
              OverlayType.flowVisualization,
              'Flow',
              Icons.waves,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOverlayButton(OverlayType type, String label, IconData icon) {
    final isSelected = type == _currentOverlayType;
    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: 120),
      child: ElevatedButton.icon(
        onPressed: () => setState(() => _currentOverlayType = type),
        icon: Icon(icon, size: 20),
        label: Text(
          label,
          style: TextStyle(fontSize: 13),
          overflow: TextOverflow.ellipsis,
        ),
        style: ElevatedButton.styleFrom(
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          backgroundColor: isSelected ? Colors.blue : Colors.grey[800],
          foregroundColor: isSelected ? Colors.white : Colors.white70,
        ),
      ),
    );
  }

  Widget _buildProcessTab() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildRecipeSection(),
          SizedBox(height: 24),
          _buildProcessControls(),
          SizedBox(height: 24),
          _buildProcessProgress(),
        ],
      ),
    );
  }

  Widget _buildRecipeSection() {
    return Card(
      color: Color(0xFF2A2A2A),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Current Recipe',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16),
            ListTile(
              title: Text(
                'TiO2 Deposition - Standard',
                style: TextStyle(color: Colors.white),
              ),
              subtitle: Text(
                '200 cycles • 2 hours estimated',
                style: TextStyle(color: Colors.white70),
              ),
              trailing: IconButton(
                icon: Icon(Icons.edit, color: Colors.blue),
                onPressed: () {},
              ),
            ),
            Divider(color: Colors.white24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildRecipeDetail('Precursor A', 'TiCl4'),
                _buildRecipeDetail('Precursor B', 'H2O'),
                _buildRecipeDetail('Carrier Gas', 'N2'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecipeDetail(String label, String value) {
    return Column(
      children: [
        Text(label, style: TextStyle(color: Colors.white70, fontSize: 12)),
        SizedBox(height: 4),
        Text(value, style: TextStyle(color: Colors.white, fontSize: 16)),
      ],
    );
  }

  Widget _buildProcessControls() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildControlButton(Icons.play_arrow, 'Start', Colors.green),
        _buildControlButton(Icons.pause, 'Pause', Colors.orange),
        _buildControlButton(Icons.stop, 'Stop', Colors.red),
      ],
    );
  }

  Widget _buildControlButton(IconData icon, String label, Color color) {
    return ElevatedButton.icon(
      onPressed: () {},
      icon: Icon(icon),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      ),
    );
  }

  Widget _buildProcessProgress() {
    return Card(
      color: Color(0xFF2A2A2A),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Process Progress',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16),
            LinearProgressIndicator(
              value: 0.45,
              backgroundColor: Colors.white10,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
            ),
            SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('90/200 cycles', style: TextStyle(color: Colors.white70)),
                Text('45% Complete', style: TextStyle(color: Colors.white70)),
              ],
            ),
            SizedBox(height: 16),
            _buildCurrentStepIndicator(),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrentStepIndicator() {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blue.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.timer, color: Colors.blue),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Current Step: Precursor A Pulse',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
                Text(
                  'Time Remaining: 2.5s',
                  style: TextStyle(color: Colors.white70),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryTab() {
    return ListView.builder(
      padding: EdgeInsets.all(16),
      itemCount: 10,
      itemBuilder: (context, index) {
        return Card(
          color: Color(0xFF2A2A2A),
          margin: EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: ListTile(
            contentPadding: EdgeInsets.all(16),
            title: Row(
              children: [
                Text(
                  'TiO2 Deposition #${1000 + index}',
                  style: TextStyle(color: Colors.white),
                ),
                SizedBox(width: 8),
                _buildProcessStatus(index),
              ],
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 8),
                Text(
                  'Started: ${DateTime.now().subtract(Duration(days: index)).toString().split('.')[0]}',
                  style: TextStyle(color: Colors.white70),
                ),
                Text(
                  '200 cycles • 2.1 hours • Operator: John Doe',
                  style: TextStyle(color: Colors.white70),
                ),
              ],
            ),
            trailing: IconButton(
              icon: Icon(Icons.chevron_right, color: Colors.white70),
              onPressed: () {},
            ),
          ),
        );
      },
    );
  }

  Widget _buildProcessStatus(int index) {
    final statuses = ['Completed', 'Failed', 'Aborted', 'Completed', 'Completed'];
    final colors = {
      'Completed': Colors.green,
      'Failed': Colors.red,
      'Aborted': Colors.orange,
    };
    final status = statuses[index % statuses.length];

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: colors[status]?.withOpacity(0.2),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: colors[status],
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _buildMaintenanceTab() {
    return ListView(
      padding: EdgeInsets.all(16),
      children: [
        _buildMaintenanceStatus(),
        SizedBox(height: 24),
        _buildMaintenanceSchedule(),
        SizedBox(height: 24),
        _buildMaintenanceLogs(),
      ],
    );
  }

  Widget _buildMaintenanceStatus() {
    return Card(
      color: Color(0xFF2A2A2A),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'System Health',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildHealthIndicator('Pump', 0.9, Colors.green),
                _buildHealthIndicator('Valves', 0.75, Colors.orange),
                _buildHealthIndicator('Sensors', 0.95, Colors.green),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHealthIndicator(String label, double value, Color color) {
    return Column(
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            CircularProgressIndicator(
              value: value,
              backgroundColor: Colors.white10,
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
            Text(
              '${(value * 100).round()}%',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        SizedBox(height: 8),
        Text(label, style: TextStyle(color: Colors.white70)),
      ],
    );
  }

  Widget _buildMaintenanceSchedule() {
    return Card(
      color: Color(0xFF2A2A2A),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Upcoming Maintenance',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16),
            _buildMaintenanceItem(
              'Pump Oil Change',
              'Due in 5 days',
              Icons.warning,
              Colors.orange,
            ),
            _buildMaintenanceItem(
              'Valve Inspection',
              'Due in 15 days',
              Icons.check_circle,
              Colors.green,
            ),
            _buildMaintenanceItem(
              'Sensor Calibration',
              'Due in 30 days',
              Icons.check_circle,
              Colors.green,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMaintenanceItem(
    String title,
    String subtitle,
    IconData icon,
    Color color,
  ) {
    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(title, style: TextStyle(color: Colors.white)),
      subtitle: Text(subtitle, style: TextStyle(color: Colors.white70)),
      trailing: TextButton(
        onPressed: () {},
        child: Text('Schedule'),
      ),
    );
  }

  Widget _buildMaintenanceLogs() {
    return Card(
      color: Color(0xFF2A2A2A),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Recent Maintenance',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16),
            _buildMaintenanceLogItem(
              'Pump Maintenance',
              'Completed on ${DateTime.now().subtract(Duration(days: 2)).toString().split(' ')[0]}',
              'John Doe',
            ),
            _buildMaintenanceLogItem(
              'Valve Replacement',
              'Completed on ${DateTime.now().subtract(Duration(days: 15)).toString().split(' ')[0]}',
              'Jane Smith',
            ),
            _buildMaintenanceLogItem(
              'System Calibration',
              'Completed on ${DateTime.now().subtract(Duration(days: 30)).toString().split(' ')[0]}',
              'Mike Johnson',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMaintenanceLogItem(String title, String date, String technician) {
    return ListTile(
      title: Text(title, style: TextStyle(color: Colors.white)),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(date, style: TextStyle(color: Colors.white70)),
          Text('Technician: $technician', style: TextStyle(color: Colors.white70)),
        ],
      ),
      trailing: IconButton(
        icon: Icon(Icons.info_outline, color: Colors.white70),
        onPressed: () {},
      ),
    );
  }

  Widget _buildEmergencyStop() {
    return FloatingActionButton(
      backgroundColor: Colors.red,
      child: Icon(Icons.stop_circle, size: 36),
      onPressed: () => _showEmergencyStopDialog(),
    );
  }

  void _showEmergencyStopDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Emergency Stop'),
        content: Text('Are you sure you want to activate emergency stop?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Emergency Stop Activated!'),
                  backgroundColor: Colors.red,
                ),
              );
            },
            child: Text('Stop', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showAlerts(BuildContext context) {
    // Hardcoded alerts dialog
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('System Alerts'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.warning, color: Colors.orange),
              title: Text('Maintenance Due'),
              subtitle: Text('Regular maintenance check required'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close'),
          ),
        ],
      ),
    );
  }

  void _handleSessionEnd(BuildContext context) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    await authProvider.signOut();
    Navigator.of(context).pushReplacementNamed('/login');
  }

  Widget _buildSystemOverviewButton() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ElevatedButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => SystemOverviewScreen(),
            ),
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blue,
          padding: EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.system_update_alt, color: Colors.white),
            SizedBox(width: 8),
            Text(
              'System Overview',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DashboardTab {
  final IconData icon;
  final String label;

  _DashboardTab(this.icon, this.label);
}

enum OverlayType {
  componentControl,
  parameterMonitor,
  flowVisualization,
}

enum MachineStatus {
  idle,
  processing,
  error,
  maintenance,
}