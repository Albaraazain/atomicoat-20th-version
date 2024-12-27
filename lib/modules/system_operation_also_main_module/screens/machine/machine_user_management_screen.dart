import 'package:flutter/material.dart';
import '../../models/machine.dart';
import '../../../../repositories/machine_repository.dart';
import '../../../../enums/user_role.dart';

class MachineUserManagementScreen extends StatefulWidget {
  final Machine machine;

  const MachineUserManagementScreen({Key? key, required this.machine}) : super(key: key);

  @override
  _MachineUserManagementScreenState createState() => _MachineUserManagementScreenState();
}

class _MachineUserManagementScreenState extends State<MachineUserManagementScreen> {
  final MachineRepository _machineRepository = MachineRepository();
  final TextEditingController _userIdController = TextEditingController();
  UserRole _selectedRole = UserRole.operator;
  bool _isLoading = false;

  @override
  void dispose() {
    _userIdController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Users'),
      ),
      body: Column(
        children: [
          _buildAddUserCard(),
          const SizedBox(height: 16),
          Expanded(
            child: _buildUserList(),
          ),
        ],
      ),
    );
  }

  Widget _buildAddUserCard() {
    return Card(
      margin: const EdgeInsets.all(16.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Add New User',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _userIdController,
              decoration: const InputDecoration(
                labelText: 'User ID',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<UserRole>(
              value: _selectedRole,
              decoration: const InputDecoration(
                labelText: 'Role',
                border: OutlineInputBorder(),
              ),
              items: [
                UserRole.operator,
                UserRole.engineer,
              ].map((role) {
                return DropdownMenuItem(
                  value: role,
                  child: Text(role.toString().split('.').last),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _selectedRole = value;
                  });
                }
              },
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _addUser,
              child: const Text('Add User'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUserList() {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _machineRepository.getMachineUsers(widget.machine.id),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        final users = snapshot.data ?? [];

        if (users.isEmpty) {
          return const Center(child: Text('No users added yet'));
        }

        return ListView.builder(
          itemCount: users.length,
          itemBuilder: (context, index) {
            final user = users[index];
            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
              child: ListTile(
                title: Text(user['userId'] as String),
                subtitle: Text(user['role'] as String),
                trailing: IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () => _removeUser(user['userId'] as String),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _addUser() async {
    final userId = _userIdController.text.trim();
    if (userId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a user ID')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await _machineRepository.addUserToMachine(
        widget.machine.id,
        userId,
        _selectedRole.toString().split('.').last,
      );

      if (mounted) {
        _userIdController.clear();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('User added successfully')),
        );
        setState(() {}); // Refresh the list
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error adding user: $e')),
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

  Future<void> _removeUser(String userId) async {
    setState(() {
      _isLoading = true;
    });

    try {
      await _machineRepository.removeUserFromMachine(widget.machine.id, userId);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('User removed successfully')),
        );
        setState(() {}); // Refresh the list
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error removing user: $e')),
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