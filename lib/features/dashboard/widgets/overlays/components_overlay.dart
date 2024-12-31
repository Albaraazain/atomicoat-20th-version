import 'package:flutter/material.dart';

class ComponentsOverlay extends StatefulWidget {
  @override
  _ComponentsOverlayState createState() => _ComponentsOverlayState();
}

class _ComponentsOverlayState extends State<ComponentsOverlay> {
  // Hardcoded component data for now
  final List<ComponentData> components = [
    ComponentData(
      name: 'Nitrogen Generator',
      position: Offset(0.1, 0.2),
      parameters: {
        'Flow Rate': '10 L/min',
        'Pressure': '2.5 bar',
        'Temperature': '25°C',
      },
    ),
    ComponentData(
      name: 'MFC',
      position: Offset(0.3, 0.4),
      parameters: {
        'Flow Rate': '5 L/min',
        'Setpoint': '5.5 L/min',
        'Valve Position': '80%',
      },
    ),
    ComponentData(
      name: 'Reaction Chamber',
      position: Offset(0.5, 0.5),
      parameters: {
        'Temperature': '250°C',
        'Pressure': '1.2 Torr',
        'Vacuum Level': '10^-3 Torr',
      },
    ),
    // Add more components as needed
  ];

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Background ALD system diagram
        Positioned.fill(
          child: Image.asset(
            'assets/ald_system_diagram.png',
            fit: BoxFit.contain,
          ),
        ),
        // Component circles
        ...components.map((component) {
          return Positioned(
            left: component.position.dx * MediaQuery.of(context).size.width,
            top: component.position.dy * MediaQuery.of(context).size.height,
            child: _buildComponentCircle(component),
          );
        }).toList(),
      ],
    );
  }

  Widget _buildComponentCircle(ComponentData component) {
    return GestureDetector(
      onTap: () => _showComponentDialog(component),
      child: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.blue.withOpacity(0.2),
          border: Border.all(
            color: Colors.blue,
            width: 2,
          ),
        ),
        child: Center(
          child: Text(
            component.name.split(' ')[0],
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontSize: 12,
            ),
          ),
        ),
      ),
    );
  }

  void _showComponentDialog(ComponentData component) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Color(0xFF2A2A2A),
        title: Text(
          component.name,
          style: TextStyle(color: Colors.white),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: component.parameters.entries.map((entry) {
            return _buildParameterRow(entry.key, entry.value);
          }).toList(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Close',
              style: TextStyle(color: Colors.blue),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildParameterRow(String name, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            name,
            style: TextStyle(color: Colors.white70),
          ),
          Row(
            children: [
              Text(
                value,
                style: TextStyle(color: Colors.white),
              ),
              SizedBox(width: 8),
              IconButton(
                icon: Icon(Icons.edit, size: 16, color: Colors.blue),
                onPressed: () => _showParameterEditDialog(name, value),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showParameterEditDialog(String parameterName, String currentValue) {
    final TextEditingController controller = TextEditingController(text: currentValue);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Color(0xFF2A2A2A),
        title: Text(
          'Edit $parameterName',
          style: TextStyle(color: Colors.white),
        ),
        content: TextField(
          controller: controller,
          style: TextStyle(color: Colors.white),
          decoration: InputDecoration(
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.blue),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.blue),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: TextStyle(color: Colors.white70),
            ),
          ),
          TextButton(
            onPressed: () {
              // TODO: Implement parameter update logic
              Navigator.pop(context);
            },
            child: Text(
              'Save',
              style: TextStyle(color: Colors.blue),
            ),
          ),
        ],
      ),
    );
  }
}

class ComponentData {
  final String name;
  final Offset position;
  final Map<String, String> parameters;

  ComponentData({
    required this.name,
    required this.position,
    required this.parameters,
  });
}