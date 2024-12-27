import 'package:flutter/material.dart';
import '../../models/machine.dart';
import '../../../../repositories/machine_repository.dart';
import 'machine_creation_screen.dart';
import 'machine_details_screen.dart';

class MachineListScreen extends StatefulWidget {
  final bool isSuperAdmin;

  const MachineListScreen({Key? key, this.isSuperAdmin = false}) : super(key: key);

  @override
  _MachineListScreenState createState() => _MachineListScreenState();
}

class _MachineListScreenState extends State<MachineListScreen> {
  final MachineRepository _machineRepository = MachineRepository();
  String _searchQuery = '';
  String? _selectedLab;
  String? _selectedInstitution;
  MachineStatus? _selectedStatus;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isSuperAdmin ? 'All Machines' : 'My Machines'),
        actions: [
          if (widget.isSuperAdmin)
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const MachineCreationScreen(),
                  ),
                );
              },
            ),
        ],
      ),
      body: Column(
        children: [
          _buildSearchAndFilters(),
          Expanded(
            child: _buildMachineList(),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchAndFilters() {
    return Card(
      margin: const EdgeInsets.all(8.0),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            TextField(
              decoration: const InputDecoration(
                hintText: 'Search machines...',
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
            const SizedBox(height: 8),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildDropdownFilter<String>(
                    value: _selectedLab,
                    hint: 'Select Lab',
                    items: const ['Lab 1', 'Lab 2'], // This should be dynamic
                    onChanged: (value) {
                      setState(() {
                        _selectedLab = value;
                      });
                    },
                  ),
                  const SizedBox(width: 8),
                  _buildDropdownFilter<String>(
                    value: _selectedInstitution,
                    hint: 'Select Institution',
                    items: const ['Institution 1', 'Institution 2'], // This should be dynamic
                    onChanged: (value) {
                      setState(() {
                        _selectedInstitution = value;
                      });
                    },
                  ),
                  const SizedBox(width: 8),
                  _buildDropdownFilter<MachineStatus>(
                    value: _selectedStatus,
                    hint: 'Status',
                    items: MachineStatus.values,
                    onChanged: (value) {
                      setState(() {
                        _selectedStatus = value;
                      });
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDropdownFilter<T>({
    required T? value,
    required String hint,
    required List<T> items,
    required void Function(T?) onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12.0),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(4.0),
      ),
      child: DropdownButton<T>(
        value: value,
        hint: Text(hint),
        items: items.map((T item) {
          return DropdownMenuItem<T>(
            value: item,
            child: Text(item.toString().split('.').last),
          );
        }).toList(),
        onChanged: onChanged,
      ),
    );
  }

  Widget _buildMachineList() {
    return FutureBuilder<List<Machine>>(
      future: widget.isSuperAdmin
          ? _machineRepository.getCollection().get().then(
              (snapshot) => snapshot.docs.map((doc) {
                final data = doc.data() as Map<String, dynamic>;
                data['id'] = doc.id;
                return Machine.fromJson(data);
              }).toList(),
            )
          : _machineRepository.getMachinesForUser('currentUserId'), // Replace with actual user ID
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        final machines = snapshot.data ?? [];
        final filteredMachines = machines.where((machine) {
          final matchesSearch = machine.serialNumber.toLowerCase().contains(_searchQuery.toLowerCase()) ||
              machine.location.toLowerCase().contains(_searchQuery.toLowerCase()) ||
              machine.labName.toLowerCase().contains(_searchQuery.toLowerCase());

          final matchesLab = _selectedLab == null || machine.labName == _selectedLab;
          final matchesInstitution =
              _selectedInstitution == null || machine.labInstitution == _selectedInstitution;
          final matchesStatus = _selectedStatus == null || machine.status == _selectedStatus;

          return matchesSearch && matchesLab && matchesInstitution && matchesStatus;
        }).toList();

        if (filteredMachines.isEmpty) {
          return const Center(child: Text('No machines found'));
        }

        return ListView.builder(
          itemCount: filteredMachines.length,
          itemBuilder: (context, index) {
            final machine = filteredMachines[index];
            return _buildMachineCard(machine);
          },
        );
      },
    );
  }

  Widget _buildMachineCard(Machine machine) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      child: ListTile(
        leading: Icon(
          Icons.science,
          color: machine.status == MachineStatus.running
              ? Colors.green
              : machine.status == MachineStatus.error
                  ? Colors.red
                  : Colors.grey,
        ),
        title: Text('${machine.model} - ${machine.serialNumber}'),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${machine.labName} - ${machine.labInstitution}'),
            Text('Status: ${machine.status.toString().split('.').last}'),
          ],
        ),
        trailing: IconButton(
          icon: const Icon(Icons.arrow_forward_ios),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => MachineDetailsScreen(machine: machine),
              ),
            );
          },
        ),
      ),
    );
  }
}