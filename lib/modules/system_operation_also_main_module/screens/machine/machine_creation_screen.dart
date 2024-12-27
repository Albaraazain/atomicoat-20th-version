import 'package:flutter/material.dart';
import '../../models/machine.dart';
import '../../../../repositories/machine_repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MachineCreationScreen extends StatefulWidget {
  const MachineCreationScreen({Key? key}) : super(key: key);

  @override
  _MachineCreationScreenState createState() => _MachineCreationScreenState();
}

class _MachineCreationScreenState extends State<MachineCreationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _machineRepository = MachineRepository();
  final _firestore = FirebaseFirestore.instance;

  String _serialNumber = '';
  String _location = '';
  String _labName = '';
  String _labInstitution = '';
  String _model = '';
  String _machineType = '';
  String _adminEmail = '';
  Map<String, dynamic> _specifications = {};

  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add New Machine'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildTextFormField(
                      label: 'Serial Number',
                      onSaved: (value) => _serialNumber = value ?? '',
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a serial number';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    _buildTextFormField(
                      label: 'Location',
                      onSaved: (value) => _location = value ?? '',
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a location';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    _buildTextFormField(
                      label: 'Lab Name',
                      onSaved: (value) => _labName = value ?? '',
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a lab name';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    _buildTextFormField(
                      label: 'Lab Institution',
                      onSaved: (value) => _labInstitution = value ?? '',
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a lab institution';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    _buildTextFormField(
                      label: 'Model',
                      onSaved: (value) => _model = value ?? '',
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a model';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    _buildTextFormField(
                      label: 'Machine Type',
                      onSaved: (value) => _machineType = value ?? '',
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a machine type';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    _buildTextFormField(
                      label: 'Admin Email',
                      onSaved: (value) => _adminEmail = value ?? '',
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter an admin email';
                        }
                        if (!value.contains('@')) {
                          return 'Please enter a valid email address';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    _buildTextFormField(
                      label: 'Additional Specifications',
                      onSaved: (value) {
                        if (value != null && value.isNotEmpty) {
                          _specifications['additional'] = value;
                        }
                      },
                      validator: (value) => null,
                      maxLines: 3,
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: _submitForm,
                      child: const Text('Create Machine'),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildTextFormField({
    required String label,
    required Function(String?) onSaved,
    required String? Function(String?) validator,
    int? maxLines,
  }) {
    return TextFormField(
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
      maxLines: maxLines ?? 1,
      onSaved: onSaved,
      validator: validator,
    );
  }

  Future<String?> _getAdminIdFromEmail(String email) async {
    final userQuery = await _firestore
        .collection('users')
        .where('email', isEqualTo: email)
        .where('role', isEqualTo: 'admin')
        .limit(1)
        .get();

    if (userQuery.docs.isEmpty) {
      return null;
    }

    return userQuery.docs.first.id;
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      _formKey.currentState!.save();

      final adminId = await _getAdminIdFromEmail(_adminEmail);
      if (adminId == null) {
        throw Exception('Admin email not found or user is not an admin');
      }

      final machine = Machine(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        serialNumber: _serialNumber,
        location: _location,
        labName: _labName,
        labInstitution: _labInstitution,
        model: _model,
        machineType: _machineType,
        installDate: DateTime.now(),
        lastMaintenance: DateTime.now(),
        adminId: adminId,
        specifications: _specifications,
      );

      await _machineRepository.add(machine.id, machine);

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Machine created successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error creating machine: $e')),
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