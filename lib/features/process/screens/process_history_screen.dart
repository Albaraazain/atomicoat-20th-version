import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/process_provider.dart';
import '../models/process_execution.dart';
import '../../experiments/screens/experiment_detail_screen.dart';

class ProcessHistoryScreen extends StatefulWidget {
  final String machineId;

  ProcessHistoryScreen({required this.machineId});

  @override
  _ProcessHistoryScreenState createState() => _ProcessHistoryScreenState();
}

class _ProcessHistoryScreenState extends State<ProcessHistoryScreen> {
  String _searchQuery = '';
  String _selectedFilter = 'All';
  String _sortBy = 'Date';
  bool _sortAscending = false;

  final List<String> _filterOptions = ['All', 'Running', 'Completed', 'Failed', 'Aborted'];
  final List<String> _sortOptions = ['Date', 'Recipe', 'Duration', 'Status'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF1A1A1A),
      appBar: AppBar(
        backgroundColor: Color(0xFF2A2A2A),
        title: Text('Process History'),
        actions: [
          IconButton(
            icon: Icon(Icons.filter_list),
            onPressed: _showFilterDialog,
          ),
          IconButton(
            icon: Icon(Icons.sort),
            onPressed: _showSortDialog,
          ),
        ],
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          _buildFilterChips(),
          Expanded(
            child: _buildProcessList(),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: EdgeInsets.all(16.0),
      child: TextField(
        style: TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: 'Search processes...',
          hintStyle: TextStyle(color: Colors.grey),
          prefixIcon: Icon(Icons.search, color: Colors.grey),
          filled: true,
          fillColor: Color(0xFF2A2A2A),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide.none,
          ),
        ),
        onChanged: (value) {
          setState(() {
            _searchQuery = value;
          });
        },
      ),
    );
  }

  Widget _buildFilterChips() {
    return Container(
      height: 50,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 16),
        children: _filterOptions.map((filter) {
          final isSelected = _selectedFilter == filter;
          return Padding(
            padding: EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Text(
                filter,
                style: TextStyle(
                  color: isSelected ? Colors.black : Colors.white,
                ),
              ),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  _selectedFilter = selected ? filter : 'All';
                });
              },
              backgroundColor: Color(0xFF2A2A2A),
              selectedColor: Colors.blue,
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildProcessList() {
    // TODO: Replace with actual data from ProcessProvider
    final processes = List.generate(10, (index) => {
      'id': 'PROC-${1000 + index}',
      'recipeName': 'TiO2 Deposition',
      'status': index == 0 ? 'Running' : (index % 3 == 1 ? 'Completed' : (index % 3 == 2 ? 'Failed' : 'Aborted')),
      'startTime': DateTime.now().subtract(Duration(hours: index)),
      'currentStep': index == 0 ? 'Precursor A Pulse' : null,
      'progress': index == 0 ? 0.45 : 1.0,
      'recipe': {
        'totalSteps': 200,
        'currentStep': index == 0 ? 90 : 200,
      },
    });

    return ListView.builder(
      padding: EdgeInsets.all(16),
      itemCount: processes.length,
      itemBuilder: (context, index) {
        final process = processes[index];
        return _buildProcessCard(process);
      },
    );
  }

  Widget _buildProcessCard(Map<String, dynamic> process) {
    final statusColors = {
      'Running': Colors.blue,
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
        onTap: () => _showProcessDetails(process['id']),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    process['id'],
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: statusColors[process['status']]?.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      process['status'],
                      style: TextStyle(
                        color: statusColors[process['status']],
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8),
              Text(
                process['recipeName'],
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                ),
              ),
              SizedBox(height: 8),
              if (process['status'] == 'Running') ...[
                Text(
                  'Current Step: ${process['currentStep']}',
                  style: TextStyle(color: Colors.grey),
                ),
                SizedBox(height: 8),
                LinearProgressIndicator(
                  value: process['progress'],
                  backgroundColor: Colors.grey[800],
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                ),
                SizedBox(height: 4),
                Text(
                  'Step ${process['recipe']['currentStep']}/${process['recipe']['totalSteps']}',
                  style: TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
              SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.access_time, color: Colors.grey, size: 16),
                  SizedBox(width: 4),
                  Text(
                    process['startTime'].toString().split('.')[0],
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Color(0xFF2A2A2A),
        title: Text(
          'Filter Processes',
          style: TextStyle(color: Colors.white),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: _filterOptions.map((filter) {
            return RadioListTile<String>(
              title: Text(filter, style: TextStyle(color: Colors.white)),
              value: filter,
              groupValue: _selectedFilter,
              onChanged: (value) {
                setState(() {
                  _selectedFilter = value!;
                });
                Navigator.pop(context);
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  void _showSortDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Color(0xFF2A2A2A),
        title: Text(
          'Sort By',
          style: TextStyle(color: Colors.white),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: _sortOptions.map((option) {
            return RadioListTile<String>(
              title: Text(option, style: TextStyle(color: Colors.white)),
              value: option,
              groupValue: _sortBy,
              onChanged: (value) {
                setState(() {
                  if (_sortBy == value) {
                    _sortAscending = !_sortAscending;
                  } else {
                    _sortBy = value!;
                    _sortAscending = true;
                  }
                });
                Navigator.pop(context);
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  void _showProcessDetails(String processId) {
    // For running processes, navigate to monitoring screen
    // For completed processes, navigate to experiment details
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ExperimentDetailScreen(experimentId: processId),
      ),
    );
  }
}
