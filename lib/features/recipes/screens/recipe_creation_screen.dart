import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/recipe.dart';
import '../providers/recipe_provider.dart';
import '../../../core/auth/providers/auth_provider.dart';

class DarkThemeColors {
  static const Color background = Color(0xFF121212);
  static const Color cardBackground = Color(0xFF1E1E1E);
  static const Color primaryText = Color(0xFFE0E0E0);
  static const Color secondaryText = Color(0xFFB0B0B0);
  static const Color accent = Color(0xFF64FFDA);
  static const Color divider = Color(0xFF2A2A2A);
  static const Color inputFill = Color(0xFF2C2C2C);
}

class RecipeCreationScreen extends StatefulWidget {
  final String? recipeId;
  final String machineId;

  RecipeCreationScreen({this.recipeId, required this.machineId});

  @override
  _RecipeCreationScreenState createState() => _RecipeCreationScreenState();
}

class _RecipeCreationScreenState extends State<RecipeCreationScreen>
    with TickerProviderStateMixin {
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late TextEditingController _substrateController;
  late TextEditingController _chamberTempController;
  late TextEditingController _pressureController;
  List<RecipeStep> _steps = [];
  bool _isPublic = false;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _descriptionController = TextEditingController();
    _substrateController = TextEditingController();
    _chamberTempController = TextEditingController();
    _pressureController = TextEditingController();
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 300),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(_animationController);
    _animationController.forward();

    if (widget.recipeId != null) {
      _loadRecipeData();
    }
  }

  void _loadRecipeData() async {
    final recipeProvider = Provider.of<RecipeProvider>(context, listen: false);
    final recipe = await recipeProvider.getRecipeById(widget.recipeId!);
    if (recipe != null) {
      setState(() {
        _nameController.text = recipe.name;
        _descriptionController.text = recipe.description;
        _substrateController.text = recipe.substrate;
        _chamberTempController.text = recipe.chamberTemperatureSetPoint.toString();
        _pressureController.text = recipe.pressureSetPoint.toString();
        _steps = List.from(recipe.steps);
        _isPublic = recipe.isPublic;
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _substrateController.dispose();
    _chamberTempController.dispose();
    _pressureController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DarkThemeColors.background,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: DarkThemeColors.background,
        title: Text(
          widget.recipeId == null ? 'Create Recipe' : 'Edit Recipe',
          style: TextStyle(color: DarkThemeColors.primaryText),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.save, color: DarkThemeColors.accent),
            onPressed: _saveRecipe,
          ),
        ],
      ),
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: SingleChildScrollView(
            padding: EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildRecipeBasicInfo(),
                SizedBox(height: 24),
                _buildGlobalParametersInputs(),
                SizedBox(height: 24),
                _buildStepsHeader(),
                SizedBox(height: 16),
                _buildStepsList(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRecipeBasicInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildTextField(
          controller: _nameController,
          label: 'Recipe Name',
          icon: Icons.title,
        ),
        SizedBox(height: 16),
        _buildTextField(
          controller: _descriptionController,
          label: 'Description',
          icon: Icons.description,
          maxLines: 3,
        ),
        SizedBox(height: 16),
        _buildTextField(
          controller: _substrateController,
          label: 'Substrate',
          icon: Icons.layers,
        ),
        SizedBox(height: 16),
        SwitchListTile(
          title: Text('Make Public', style: TextStyle(color: DarkThemeColors.primaryText)),
          value: _isPublic,
          onChanged: (value) => setState(() => _isPublic = value),
          activeColor: DarkThemeColors.accent,
        ),
      ],
    );
  }

  Widget _buildGlobalParametersInputs() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Global Parameters',
          style: TextStyle(
            color: DarkThemeColors.primaryText,
            fontSize: 18,
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: 16),
        _buildTextField(
          controller: _chamberTempController,
          label: 'Chamber Temperature (°C)',
          icon: Icons.thermostat,
          keyboardType: TextInputType.numberWithOptions(decimal: true),
        ),
        SizedBox(height: 16),
        _buildTextField(
          controller: _pressureController,
          label: 'Pressure (atm)',
          icon: Icons.compress,
          keyboardType: TextInputType.numberWithOptions(decimal: true),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
  }) {
    return TextField(
      controller: controller,
      style: TextStyle(color: DarkThemeColors.primaryText),
      keyboardType: keyboardType,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: DarkThemeColors.secondaryText),
        prefixIcon: Icon(icon, color: DarkThemeColors.accent),
        filled: true,
        fillColor: DarkThemeColors.inputFill,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: DarkThemeColors.accent),
        ),
      ),
    );
  }

  Widget _buildStepsHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Recipe Steps',
          style: TextStyle(
            color: DarkThemeColors.primaryText,
            fontSize: 18,
            fontWeight: FontWeight.w500,
          ),
        ),
        ElevatedButton.icon(
          icon: Icon(Icons.add),
          label: Text('Add Step'),
          style: ElevatedButton.styleFrom(
            foregroundColor: DarkThemeColors.background,
            backgroundColor: DarkThemeColors.accent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          onPressed: () => _showAddStepDialog(),
        ),
      ],
    );
  }

  Widget _buildStepsList() {
    return ReorderableListView(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      children: _steps.asMap().entries.map((entry) {
        final index = entry.key;
        final step = entry.value;
        return _buildStepCard(step, index);
      }).toList(),
      onReorder: (oldIndex, newIndex) {
        setState(() {
          if (newIndex > oldIndex) {
            newIndex -= 1;
          }
          final RecipeStep item = _steps.removeAt(oldIndex);
          _steps.insert(newIndex, item);
        });
      },
    );
  }

  Widget _buildStepCard(RecipeStep step, int index) {
    return Card(
      key: ValueKey(step.id),
      margin: EdgeInsets.only(bottom: 16),
      color: DarkThemeColors.cardBackground,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: ExpansionTile(
        title: Text(
          'Step ${index + 1}: ${step.name}',
          style: TextStyle(color: DarkThemeColors.primaryText),
        ),
        subtitle: Text(
          step.description,
          style: TextStyle(color: DarkThemeColors.secondaryText),
        ),
        children: [
          Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildStepParameters(step),
                if (step.type == StepType.loop && step.subSteps != null)
                  _buildLoopSubSteps(step),
              ],
            ),
          ),
        ],
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(Icons.edit, color: DarkThemeColors.accent),
              onPressed: () => _showEditStepDialog(step, index),
            ),
            IconButton(
              icon: Icon(Icons.delete, color: Colors.red),
              onPressed: () => _showDeleteStepDialog(index),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStepParameters(RecipeStep step) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Parameters:',
          style: TextStyle(
            color: DarkThemeColors.primaryText,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 8),
        ...step.parameters.entries.map((entry) {
          return Padding(
            padding: EdgeInsets.only(bottom: 8),
            child: Row(
              children: [
                Text(
                  '${entry.key}: ',
                  style: TextStyle(color: DarkThemeColors.secondaryText),
                ),
                Text(
                  '${entry.value}',
                  style: TextStyle(color: DarkThemeColors.primaryText),
                ),
              ],
            ),
          );
        }).toList(),
      ],
    );
  }

  Widget _buildLoopSubSteps(RecipeStep loopStep) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 16),
        Text(
          'Loop Steps:',
          style: TextStyle(
            color: DarkThemeColors.primaryText,
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: 8),
        ...loopStep.subSteps!.asMap().entries.map((entry) {
          int index = entry.key;
          RecipeStep subStep = entry.value;
          return Card(
            margin: EdgeInsets.only(bottom: 8),
            color: DarkThemeColors.inputFill,
            child: ListTile(
              title: Text(
                'Substep ${index + 1}: ${subStep.name}',
                style: TextStyle(color: DarkThemeColors.primaryText),
              ),
              subtitle: Text(
                subStep.description,
                style: TextStyle(color: DarkThemeColors.secondaryText),
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: Icon(Icons.edit, color: DarkThemeColors.accent),
                    onPressed: () => _showEditStepDialog(subStep, index, parentStep: loopStep),
                  ),
                  IconButton(
                    icon: Icon(Icons.delete, color: Colors.red),
                    onPressed: () {
                      setState(() {
                        loopStep.subSteps!.removeAt(index);
                      });
                    },
                  ),
                ],
              ),
            ),
          );
        }).toList(),
        ElevatedButton(
          child: Text('Add Loop Step'),
          style: ElevatedButton.styleFrom(
            foregroundColor: DarkThemeColors.background,
            backgroundColor: DarkThemeColors.accent,
          ),
          onPressed: () => _showAddStepDialog(parentStep: loopStep),
        ),
      ],
    );
  }

  void _showAddStepDialog({RecipeStep? parentStep}) {
    showModalBottomSheet(
      context: context,
      backgroundColor: DarkThemeColors.cardBackground,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: Text(
                  'Add Step',
                  style: TextStyle(
                    color: DarkThemeColors.primaryText,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              ...StepType.values.map((type) {
                return ListTile(
                  leading: Icon(_getStepTypeIcon(type), color: DarkThemeColors.accent),
                  title: Text(
                    _getStepTypeName(type),
                    style: TextStyle(color: DarkThemeColors.primaryText),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    _addStep(type, parentStep?.subSteps ?? _steps);
                  },
                );
              }).toList(),
            ],
          ),
        );
      },
    );
  }

  IconData _getStepTypeIcon(StepType type) {
    switch (type) {
      case StepType.loop:
        return Icons.loop;
      case StepType.valve:
        return Icons.water;
      case StepType.purge:
        return Icons.air;
      case StepType.setParameter:
        return Icons.settings;
    }
  }

  String _getStepTypeName(StepType type) {
    switch (type) {
      case StepType.loop:
        return 'Loop';
      case StepType.valve:
        return 'Valve Operation';
      case StepType.purge:
        return 'Purge';
      case StepType.setParameter:
        return 'Set Parameter';
    }
  }

  void _addStep(StepType type, List<RecipeStep> steps) {
    final newStep = RecipeStep(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: _getStepTypeName(type),
      description: 'New ${_getStepTypeName(type)} step',
      type: type,
      parameters: _getDefaultParameters(type),
      subSteps: type == StepType.loop ? [] : null,
    );

    setState(() {
      steps.add(newStep);
    });
  }

  Map<String, dynamic> _getDefaultParameters(StepType type) {
    switch (type) {
      case StepType.loop:
        return {'iterations': 1};
      case StepType.valve:
        return {'valve': 'A', 'duration': 5.0};
      case StepType.purge:
        return {'duration': 10.0};
      case StepType.setParameter:
        return {'parameter': '', 'value': 0.0};
    }
  }

  void _showEditStepDialog(RecipeStep step, int index, {RecipeStep? parentStep}) {
    // Implementation for editing a step
    // This would be similar to the example but adapted to our model
  }

  void _showDeleteStepDialog(int index) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: DarkThemeColors.cardBackground,
          title: Text(
            'Delete Step',
            style: TextStyle(color: DarkThemeColors.primaryText),
          ),
          content: Text(
            'Are you sure you want to delete this step?',
            style: TextStyle(color: DarkThemeColors.primaryText),
          ),
          actions: [
            TextButton(
              child: Text('Cancel', style: TextStyle(color: DarkThemeColors.accent)),
              onPressed: () => Navigator.pop(context),
            ),
            TextButton(
              child: Text('Delete', style: TextStyle(color: Colors.red)),
              onPressed: () {
                Navigator.pop(context);
                setState(() => _steps.removeAt(index));
              },
            ),
          ],
        );
      },
    );
  }

  void _saveRecipe() async {
    if (_nameController.text.isEmpty) {
      _showError('Please enter a recipe name');
      return;
    }

    if (_steps.isEmpty) {
      _showError('Please add at least one step to the recipe');
      return;
    }

    final recipeProvider = Provider.of<RecipeProvider>(context, listen: false);
    if (recipeProvider.currentUserId == null) {
      _showError('You must be logged in to create a recipe');
      return;
    }

    final recipe = Recipe(
      id: widget.recipeId ?? DateTime.now().millisecondsSinceEpoch.toString(),
      name: _nameController.text,
      description: _descriptionController.text,
      steps: _steps,
      isPublic: _isPublic,
      createdAt: DateTime.now(),
      updatedAt: widget.recipeId != null ? DateTime.now() : null,
      createdBy: recipeProvider.currentUserId!,
      machineId: widget.machineId,
      substrate: _substrateController.text,
      chamberTemperatureSetPoint: double.tryParse(_chamberTempController.text) ?? 0.0,
      pressureSetPoint: double.tryParse(_pressureController.text) ?? 0.0,
    );

    try {
      final recipeProvider = Provider.of<RecipeProvider>(context, listen: false);

      if (widget.recipeId == null) {
        await recipeProvider.createRecipe(recipe);
      } else {
        await recipeProvider.updateRecipe(recipe);
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Recipe saved successfully'),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pop(context);
    } catch (e) {
      _showError('Error saving recipe: $e');
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }
}
