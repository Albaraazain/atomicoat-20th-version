import 'package:flutter/material.dart';

class MachineEditScreen extends StatefulWidget {
  final String machineId;

  const MachineEditScreen({required this.machineId});

  @override
  _MachineEditScreenState createState() => _MachineEditScreenState();
}

class _MachineEditScreenState extends State<MachineEditScreen> {
  final _formKey = GlobalKey<FormState>();
  final _machineNameController = TextEditingController(text: 'ALD Machine 1');
  final _serialNumberController = TextEditingController(text: 'ALD-1001');
  final _locationController = TextEditingController(text: 'Lab 101');
  final _descriptionController = TextEditingController(
    text: 'Thermal ALD system for thin film deposition',
  );

  String _selectedMachineType = 'Thermal ALD';
  String _selectedModel = 'Model A';

  @override
  void dispose() {
    _machineNameController.dispose();
    _serialNumberController.dispose();
    _locationController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF1A1A1A),
      appBar: AppBar(
        backgroundColor: Color(0xFF2A2A2A),
        title: Text('Edit Machine'),
        actions: [
          TextButton(
            onPressed: _handleSave,
            child: Text('Save'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionTitle('Basic Information'),
              SizedBox(height: 16),
              _buildTextField(
                controller: _machineNameController,
                label: 'Machine Name',
                hint: 'Enter machine name',
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter machine name';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              _buildTextField(
                controller: _serialNumberController,
                label: 'Serial Number',
                hint: 'Enter serial number',
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter serial number';
                  }
                  return null;
                },
              ),
              SizedBox(height: 24),
              _buildSectionTitle('Machine Specifications'),
              SizedBox(height: 16),
              _buildDropdown(
                label: 'Machine Type',
                value: _selectedMachineType,
                items: ['Thermal ALD', 'Plasma ALD', 'Spatial ALD'],
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _selectedMachineType = value);
                  }
                },
              ),
              SizedBox(height: 16),
              _buildDropdown(
                label: 'Model',
                value: _selectedModel,
                items: ['Model A', 'Model B', 'Model C'],
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _selectedModel = value);
                  }
                },
              ),
              SizedBox(height: 24),
              _buildSectionTitle('Location Information'),
              SizedBox(height: 16),
              _buildTextField(
                controller: _locationController,
                label: 'Location',
                hint: 'Enter machine location',
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter location';
                  }
                  return null;
                },
              ),
              SizedBox(height: 24),
              _buildSectionTitle('Additional Information'),
              SizedBox(height: 16),
              _buildTextField(
                controller: _descriptionController,
                label: 'Description',
                hint: 'Enter machine description',
                maxLines: 3,
              ),
              SizedBox(height: 32),
              _buildDangerZone(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        color: Colors.white,
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    String? Function(String?)? validator,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(color: Colors.white70),
        ),
        SizedBox(height: 8),
        TextFormField(
          controller: controller,
          validator: validator,
          maxLines: maxLines,
          style: TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.white38),
            filled: true,
            fillColor: Color(0xFF2A2A2A),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.white24),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.blue),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.red),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.red),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdown({
    required String label,
    required String value,
    required List<String> items,
    required void Function(String?) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(color: Colors.white70),
        ),
        SizedBox(height: 8),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: Color(0xFF2A2A2A),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.white24),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              isExpanded: true,
              dropdownColor: Color(0xFF2A2A2A),
              style: TextStyle(color: Colors.white),
              items: items.map((String item) {
                return DropdownMenuItem<String>(
                  value: item,
                  child: Text(item),
                );
              }).toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDangerZone() {
    return Card(
      color: Color(0xFF2A2A2A),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Danger Zone',
              style: TextStyle(
                color: Colors.red,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16),
            Text(
              'The actions below are destructive and cannot be undone.',
              style: TextStyle(color: Colors.white70),
            ),
            SizedBox(height: 16),
            OutlinedButton(
              onPressed: _showDeleteConfirmation,
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.red,
                side: BorderSide(color: Colors.red),
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.delete),
                  SizedBox(width: 8),
                  Text('Delete Machine'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleSave() {
    if (_formKey.currentState?.validate() ?? false) {
      // TODO: Implement save logic
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Changes saved successfully')),
      );
      Navigator.pop(context);
    }
  }

  void _showDeleteConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Color(0xFF2A2A2A),
        title: Text(
          'Delete Machine',
          style: TextStyle(color: Colors.white),
        ),
        content: Text(
          'Are you sure you want to delete this machine? This action cannot be undone.',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              // TODO: Implement delete logic
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Go back to previous screen
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Machine deleted')),
              );
            },
            child: Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}