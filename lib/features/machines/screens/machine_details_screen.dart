import 'package:flutter/material.dart';

class MachineDetailsScreen extends StatelessWidget {
  final String machineId;

  const MachineDetailsScreen({required this.machineId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF1A1A1A),
      appBar: AppBar(
        backgroundColor: Color(0xFF2A2A2A),
        title: Text('Machine Details'),
        actions: [
          IconButton(
            icon: Icon(Icons.edit),
            onPressed: () => Navigator.pushNamed(
              context,
              '/machines/edit',
              arguments: machineId,
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildMachineHeader(),
            SizedBox(height: 24),
            _buildSpecificationsCard(),
            SizedBox(height: 24),
            _buildStatusCard(),
            SizedBox(height: 24),
            _buildMaintenanceCard(),
            SizedBox(height: 24),
            _buildUsageStatistics(),
          ],
        ),
      ),
    );
  }

  Widget _buildMachineHeader() {
    return Card(
      color: Color(0xFF2A2A2A),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
                        'ALD Machine 1',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Serial: ALD-1001',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
                _buildStatusBadge('IDLE'),
              ],
            ),
            SizedBox(height: 16),
            _buildInfoRow('Location', 'Lab 101'),
            _buildInfoRow('Installation Date', '01/01/2023'),
            _buildInfoRow('Last Maintenance', '15/12/2023'),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.2),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: Colors.grey,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text(
            '$label: ',
            style: TextStyle(color: Colors.white54),
          ),
          Text(
            value,
            style: TextStyle(color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildSpecificationsCard() {
    return Card(
      color: Color(0xFF2A2A2A),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Specifications',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16),
            _buildSpecRow('Machine Type', 'Thermal ALD'),
            _buildSpecRow('Model', 'Model A'),
            _buildSpecRow('Chamber Size', '200mm'),
            _buildSpecRow('Temperature Range', '25-350°C'),
            _buildSpecRow('Base Pressure', '10^-6 Torr'),
          ],
        ),
      ),
    );
  }

  Widget _buildSpecRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Colors.white70)),
          Text(value, style: TextStyle(color: Colors.white)),
        ],
      ),
    );
  }

  Widget _buildStatusCard() {
    return Card(
      color: Color(0xFF2A2A2A),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Current Status',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16),
            GridView.count(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: 1.5,
              children: [
                _buildStatusItem('Temperature', '200°C', Colors.orange),
                _buildStatusItem('Pressure', '2.5 mTorr', Colors.blue),
                _buildStatusItem('Flow Rate', '20 sccm', Colors.green),
                _buildStatusItem('Power', '1000W', Colors.purple),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusItem(String label, String value, Color color) {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: color.withOpacity(0.7),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMaintenanceCard() {
    return Card(
      color: Color(0xFF2A2A2A),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Maintenance',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton(
                  onPressed: () {},
                  child: Text('View All'),
                ),
              ],
            ),
            SizedBox(height: 16),
            _buildMaintenanceItem(
              title: 'Pump Oil Change',
              date: 'Due in 5 days',
              status: 'Pending',
              statusColor: Colors.orange,
            ),
            _buildMaintenanceItem(
              title: 'Valve Inspection',
              date: 'Completed on 01/12/2023',
              status: 'Completed',
              statusColor: Colors.green,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMaintenanceItem({
    required String title,
    required String date,
    required String status,
    required Color statusColor,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(color: Colors.white)),
                SizedBox(height: 4),
                Text(date, style: TextStyle(color: Colors.white54, fontSize: 12)),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: statusColor.withOpacity(0.3)),
            ),
            child: Text(
              status,
              style: TextStyle(color: statusColor, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUsageStatistics() {
    return Card(
      color: Color(0xFF2A2A2A),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Usage Statistics',
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
                _buildStatItem('Total Processes', '1,234'),
                _buildStatItem('Total Hours', '2,456'),
                _buildStatItem('Success Rate', '98%'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(color: Colors.white54, fontSize: 12),
        ),
      ],
    );
  }
}