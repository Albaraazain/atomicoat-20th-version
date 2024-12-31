import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/auth/providers/auth_provider.dart';
import '../models/experiment.dart';
import '../providers/experiment_provider.dart';
import '../widgets/experiment_list_view.dart';
import '../widgets/experiment_detail_view.dart';

class ExperimentHistoryScreen extends StatefulWidget {
  final String machineId;

  ExperimentHistoryScreen({required this.machineId});

  @override
  _ExperimentHistoryScreenState createState() => _ExperimentHistoryScreenState();
}

class _ExperimentHistoryScreenState extends State<ExperimentHistoryScreen> {
  String _searchQuery = '';
  String _selectedFilter = 'All';
  String _sortBy = 'Date';
  bool _sortAscending = false;

  final List<String> _filterOptions = ['All', 'Completed', 'Failed', 'Aborted'];
  final List<String> _sortOptions = ['Date', 'Recipe', 'Duration', 'Status'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF1A1A1A),
      appBar: AppBar(
        backgroundColor: Color(0xFF2A2A2A),
        title: Text('Experiment History'),
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
            child: _buildExperimentList(),
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
          hintText: 'Search experiments...',
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

  Widget _buildExperimentList() {
    // TODO: Replace with actual data from ExperimentProvider
    final experiments = List.generate(10, (index) => {
      'id': 'EXP-${1000 + index}',
      'recipeName': 'TiO2 Deposition',
      'status': index % 3 == 0 ? 'Completed' : (index % 3 == 1 ? 'Failed' : 'Aborted'),
      'startTime': DateTime.now().subtract(Duration(days: index)),
      'duration': Duration(hours: 2, minutes: 30),
      'operator': 'John Doe',
    });

    // Apply filters
    final filteredExperiments = experiments.where((exp) {
      if (_selectedFilter != 'All' && exp['status'] != _selectedFilter) {
        return false;
      }
      if (_searchQuery.isNotEmpty) {
        return exp['recipeName'].toString().toLowerCase().contains(_searchQuery.toLowerCase()) ||
               exp['id'].toString().toLowerCase().contains(_searchQuery.toLowerCase());
      }
      return true;
    }).toList();

    // Apply sorting
    filteredExperiments.sort((a, b) {
      switch (_sortBy) {
        case 'Date':
          return _sortAscending
              ? (a['startTime'] as DateTime).compareTo(b['startTime'] as DateTime)
              : (b['startTime'] as DateTime).compareTo(a['startTime'] as DateTime);
        case 'Recipe':
          return _sortAscending
              ? a['recipeName'].toString().compareTo(b['recipeName'].toString())
              : b['recipeName'].toString().compareTo(a['recipeName'].toString());
        case 'Duration':
          return _sortAscending
              ? (a['duration'] as Duration).compareTo(b['duration'] as Duration)
              : (b['duration'] as Duration).compareTo(a['duration'] as Duration);
        case 'Status':
          return _sortAscending
              ? a['status'].toString().compareTo(b['status'].toString())
              : b['status'].toString().compareTo(a['status'].toString());
        default:
          return 0;
      }
    });

    return ExperimentListView(
      experiments: filteredExperiments,
      onExperimentTap: (experimentId) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ExperimentDetailView(experimentId: experimentId),
          ),
        );
      },
    );
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Color(0xFF2A2A2A),
        title: Text(
          'Filter Experiments',
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
}
