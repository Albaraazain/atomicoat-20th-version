import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/recipe.dart';
import '../providers/recipe_provider.dart';

class DarkThemeColors {
  static const Color background = Color(0xFF121212);
  static const Color cardBackground = Color(0xFF1E1E1E);
  static const Color primaryText = Color(0xFFE0E0E0);
  static const Color secondaryText = Color(0xFFB0B0B0);
  static const Color accent = Color(0xFF64FFDA);
  static const Color divider = Color(0xFF2A2A2A);
  static const Color inputFill = Color(0xFF2C2C2C);
}

class RecipeDetailScreen extends StatefulWidget {
  final String? recipeId;

  const RecipeDetailScreen({Key? key, this.recipeId}) : super(key: key);

  @override
  _RecipeDetailScreenState createState() => _RecipeDetailScreenState();
}

class _RecipeDetailScreenState extends State<RecipeDetailScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late TextEditingController _substrateController;
  late TextEditingController _temperatureController;
  late TextEditingController _pressureController;
  bool _isPublic = false;
  List<RecipeStep> _steps = [];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _descriptionController = TextEditingController();
    _substrateController = TextEditingController();
    _temperatureController = TextEditingController(text: '150.0');
    _pressureController = TextEditingController(text: '1.0');

    if (widget.recipeId != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _loadRecipe();
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _substrateController.dispose();
    _temperatureController.dispose();
    _pressureController.dispose();
    super.dispose();
  }

  Future<void> _loadRecipe() async {
    if (widget.recipeId == null) return;

    final provider = Provider.of<RecipeProvider>(context, listen: false);
    final recipe = await provider.getRecipeById(widget.recipeId!);

    if (recipe == null) {
      Navigator.of(context).pop();
      return;
    }

    setState(() {
    _nameController.text = recipe.name;
    _descriptionController.text = recipe.description;
    _substrateController.text = recipe.substrate;
    _temperatureController.text = recipe.chamberTemperatureSetPoint.toString();
    _pressureController.text = recipe.pressureSetPoint.toString();
    _isPublic = recipe.isPublic;
    _steps = List.from(recipe.steps);
    });
  }

  Future<void> _saveRecipe() async {
    if (!_formKey.currentState!.validate()) return;

    final provider = Provider.of<RecipeProvider>(context, listen: false);
    final recipe = Recipe(
      id: widget.recipeId ?? DateTime.now().millisecondsSinceEpoch.toString(),
      name: _nameController.text,
      description: _descriptionController.text,
      steps: _steps,
      isPublic: _isPublic,
      createdAt: DateTime.now(),
      updatedAt: widget.recipeId != null ? DateTime.now() : null,
      createdBy: provider.currentUserId!,
      machineId: provider.currentMachineId!,
      substrate: _substrateController.text,
      chamberTemperatureSetPoint: double.parse(_temperatureController.text),
      pressureSetPoint: double.parse(_pressureController.text),
    );

    if (widget.recipeId == null) {
      await provider.createRecipe(recipe);
    } else {
      await provider.updateRecipe(recipe);
    }

    Navigator.of(context).pop(true);
  }

  void _addStep() {
    showDialog(
      context: context,
      builder: (context) => _StepDialog(
        onSave: (step) {
          setState(() {
            _steps.add(step);
          });
        },
      ),
    );
  }

  void _editStep(int index) {
    showDialog(
      context: context,
      builder: (context) => _StepDialog(
        initialStep: _steps[index],
        onSave: (step) {
          setState(() {
            _steps[index] = step;
          });
        },
      ),
    );
  }

  void _removeStep(int index) {
    setState(() {
      _steps.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.recipeId == null ? 'New Recipe' : 'Edit Recipe'),
        actions: [
          IconButton(
            icon: Icon(Icons.save),
            onPressed: _saveRecipe,
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'Recipe Name',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a recipe name';
                }
                return null;
              },
            ),
            SizedBox(height: 16),
            TextFormField(
              controller: _descriptionController,
              decoration: InputDecoration(
                labelText: 'Description (optional)',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            SizedBox(height: 16),
            TextFormField(
              controller: _substrateController,
              decoration: InputDecoration(
                labelText: 'Substrate',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a substrate';
                }
                return null;
              },
            ),
            SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _temperatureController,
                    decoration: InputDecoration(
                      labelText: 'Temperature (°C)',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a temperature';
                      }
                      if (double.tryParse(value) == null) {
                        return 'Please enter a valid number';
                      }
                      return null;
                    },
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: _pressureController,
                    decoration: InputDecoration(
                      labelText: 'Pressure (atm)',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a pressure';
                      }
                      if (double.tryParse(value) == null) {
                        return 'Please enter a valid number';
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            SwitchListTile(
              title: Text('Make Recipe Public'),
              subtitle: Text(
                'Allow other researchers to view and clone this recipe',
              ),
              value: _isPublic,
              onChanged: (value) {
                setState(() {
                  _isPublic = value;
                });
              },
            ),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Recipe Steps',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                IconButton(
                  icon: Icon(Icons.add),
                  onPressed: _addStep,
                ),
              ],
            ),
            SizedBox(height: 8),
            if (_steps.isEmpty)
              Center(
                child: Text(
                  'No steps added yet',
                  style: TextStyle(color: Colors.grey),
                ),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: _steps.length,
                itemBuilder: (context, index) {
                  final step = _steps[index];
                  return Card(
                    child: ListTile(
                      title: Text(_getStepDescription(step)),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: Icon(Icons.edit),
                            onPressed: () => _editStep(index),
                          ),
                          IconButton(
                            icon: Icon(Icons.delete),
                            onPressed: () => _removeStep(index),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  String _getStepDescription(RecipeStep step) {
    switch (step.type) {
      case StepType.valve:
        return '${step.name}: Open ${step.parameters['valveType']} for ${step.parameters['duration']}s at ${step.parameters['temperature']}°C, ${step.parameters['pressure']} atm';
      case StepType.purge:
        return '${step.name}: Purge for ${step.parameters['duration']}s at ${step.parameters['flowRate']} sccm';
      case StepType.loop:
        return '${step.name}: Loop ${step.parameters['iterations']} times';
      case StepType.setParameter:
        return '${step.name}: Set ${step.parameters['parameter']} of ${step.parameters['component']} to ${step.parameters['value']}';
      default:
        return 'Unknown step';
    }
  }
}

Map<String, dynamic> _getDefaultParameters(StepType type) {
  switch (type) {
    case StepType.valve:
      return {
        'valveType': 'valveA',
        'duration': 5.0,
        'temperature': 200.0,
        'pressure': 1.0,
      };
    case StepType.purge:
      return {
        'duration': 10.0,
        'flowRate': 100.0,
      };
    case StepType.loop:
      return {
        'iterations': 1,
      };
    case StepType.setParameter:
      return {
        'component': '',
        'parameter': '',
        'value': 0.0,
      };
  }
}

class _StepDialog extends StatefulWidget {
  final RecipeStep? initialStep;
  final Function(RecipeStep) onSave;

  const _StepDialog({
    Key? key,
    this.initialStep,
    required this.onSave,
  }) : super(key: key);

  @override
  __StepDialogState createState() => __StepDialogState();
}

class __StepDialogState extends State<_StepDialog> {
  late StepType _selectedType;
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late Map<String, dynamic> _parameters;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _descriptionController = TextEditingController();
    if (widget.initialStep != null) {
      _selectedType = widget.initialStep!.type;
      _parameters = Map.from(widget.initialStep!.parameters);
      _nameController.text = widget.initialStep!.name;
      _descriptionController.text = widget.initialStep!.description;
    } else {
      _selectedType = StepType.valve;
      _parameters = _getDefaultParameters(StepType.valve);
      _nameController.text = 'New Step';
      _descriptionController.text = 'Step description';
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Widget _buildParameterFields() {
    switch (_selectedType) {
      case StepType.valve:
        return Column(
          children: [
            DropdownButtonFormField<String>(
              value: _parameters['valveType'] as String,
              decoration: InputDecoration(labelText: 'Valve Type'),
              items: ['valveA', 'valveB'].map((type) {
                return DropdownMenuItem(
                  value: type,
                  child: Text(type),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _parameters['valveType'] = value;
                });
              },
            ),
            TextFormField(
              initialValue: _parameters['duration'].toString(),
              decoration: InputDecoration(labelText: 'Duration (s)'),
              keyboardType: TextInputType.number,
              onChanged: (value) {
                _parameters['duration'] = double.tryParse(value) ?? 0.0;
              },
            ),
            TextFormField(
              initialValue: _parameters['temperature'].toString(),
              decoration: InputDecoration(labelText: 'Temperature (°C)'),
              keyboardType: TextInputType.number,
              onChanged: (value) {
                _parameters['temperature'] = double.tryParse(value) ?? 0.0;
              },
            ),
            TextFormField(
              initialValue: _parameters['pressure'].toString(),
              decoration: InputDecoration(labelText: 'Pressure (atm)'),
              keyboardType: TextInputType.number,
              onChanged: (value) {
                _parameters['pressure'] = double.tryParse(value) ?? 0.0;
              },
            ),
          ],
        );
      case StepType.purge:
        return Column(
          children: [
            TextFormField(
              initialValue: _parameters['duration'].toString(),
              decoration: InputDecoration(labelText: 'Duration (s)'),
              keyboardType: TextInputType.number,
              onChanged: (value) {
                _parameters['duration'] = double.tryParse(value) ?? 0.0;
              },
            ),
            TextFormField(
              initialValue: _parameters['flowRate'].toString(),
              decoration: InputDecoration(labelText: 'Flow Rate (sccm)'),
              keyboardType: TextInputType.number,
              onChanged: (value) {
                _parameters['flowRate'] = double.tryParse(value) ?? 0.0;
              },
            ),
          ],
        );
      case StepType.loop:
        return TextFormField(
          initialValue: _parameters['iterations'].toString(),
          decoration: InputDecoration(labelText: 'Number of Iterations'),
          keyboardType: TextInputType.number,
          onChanged: (value) {
            _parameters['iterations'] = int.tryParse(value) ?? 1;
          },
        );
      case StepType.setParameter:
        return Column(
          children: [
            TextFormField(
              initialValue: _parameters['component'].toString(),
              decoration: InputDecoration(labelText: 'Component Name'),
              onChanged: (value) {
                _parameters['component'] = value;
              },
            ),
            TextFormField(
              initialValue: _parameters['parameter'].toString(),
              decoration: InputDecoration(labelText: 'Parameter Name'),
              onChanged: (value) {
                _parameters['parameter'] = value;
              },
            ),
            TextFormField(
              initialValue: _parameters['value'].toString(),
              decoration: InputDecoration(labelText: 'Value'),
              keyboardType: TextInputType.number,
              onChanged: (value) {
                _parameters['value'] = double.tryParse(value) ?? 0.0;
              },
            ),
          ],
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.initialStep == null ? 'Add Step' : 'Edit Step'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _nameController,
              decoration: InputDecoration(labelText: 'Step Name'),
            ),
            SizedBox(height: 16),
            TextFormField(
              controller: _descriptionController,
              decoration: InputDecoration(labelText: 'Description'),
            ),
            SizedBox(height: 16),
            DropdownButtonFormField<StepType>(
              value: _selectedType,
              decoration: InputDecoration(labelText: 'Step Type'),
              items: StepType.values.map((type) {
                return DropdownMenuItem(
                  value: type,
                  child: Text(type.toString().split('.').last),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedType = value!;
                  _parameters = _getDefaultParameters(value);
                });
              },
            ),
            SizedBox(height: 16),
            _buildParameterFields(),
          ],
        ),
      ),
      actions: [
        TextButton(
          child: Text('Cancel'),
          onPressed: () => Navigator.of(context).pop(),
        ),
        TextButton(
          child: Text('Save'),
          onPressed: () {
            final step = RecipeStep(
              id: widget.initialStep?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
              name: _nameController.text,
              description: _descriptionController.text,
              type: _selectedType,
              parameters: Map.from(_parameters),
              subSteps: _selectedType == StepType.loop ? [] : null,
            );
            widget.onSave(step);
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }
}
