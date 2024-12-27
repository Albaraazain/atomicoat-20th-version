// lib/modules/system_operation_also_main_module/providers/recipe_provider.dart

import 'package:flutter/foundation.dart';
import '../../../repositories/recipe_reposiory.dart';
import '../../../services/auth_service.dart';
import '../models/recipe.dart';

class RecipeProvider with ChangeNotifier {
  final RecipeRepository _recipeRepository = RecipeRepository();
  final AuthService _authService;
  String? _currentMachineId;
  List<Recipe> _recipes = [];
  List<Recipe> _publicRecipes = [];

  List<Recipe> get recipes => _recipes;
  List<Recipe> get publicRecipes => _publicRecipes;
  String? get currentMachineId => _currentMachineId;

  RecipeProvider(this._authService);

  // Set current machine and load its recipes
  Future<void> setCurrentMachine(String machineId) async {
    _currentMachineId = machineId;
    await loadRecipes();
  }

  // Load recipes for current machine
  Future<void> loadRecipes() async {
    try {
      if (_currentMachineId == null) return;

      // Load machine's recipes
      _recipes = await _recipeRepository.getMachineRecipes(_currentMachineId!);

      // Load public recipes
      _publicRecipes = await _recipeRepository.getPublicRecipes(_currentMachineId!);

      notifyListeners();
    } catch (e) {
      print('Error loading recipes: $e');
    }
  }

  // Add new recipe
  Future<void> addRecipe(Recipe recipe) async {
    try {
      String? userId = _authService.currentUser?.uid;
      if (userId == null || _currentMachineId == null) return;

      // Set creator and machine ID
      recipe.createdBy = userId;
      recipe.machineId = _currentMachineId!;

      await _recipeRepository.createRecipe(recipe);
      _recipes.add(recipe);
      if (recipe.isPublic) {
        _publicRecipes.add(recipe);
      }
      notifyListeners();
    } catch (e) {
      print('Error adding recipe: $e');
      rethrow;
    }
  }

  // Update existing recipe
  Future<void> updateRecipe(Recipe updatedRecipe) async {
    try {
      await _recipeRepository.updateRecipe(updatedRecipe);

      // Update in local lists
      int index = _recipes.indexWhere((recipe) => recipe.id == updatedRecipe.id);
      if (index != -1) {
        _recipes[index] = updatedRecipe;
      }

      if (updatedRecipe.isPublic) {
        int publicIndex = _publicRecipes.indexWhere((recipe) => recipe.id == updatedRecipe.id);
        if (publicIndex != -1) {
          _publicRecipes[publicIndex] = updatedRecipe;
        } else {
          _publicRecipes.add(updatedRecipe);
        }
      } else {
        _publicRecipes.removeWhere((recipe) => recipe.id == updatedRecipe.id);
      }

      notifyListeners();
    } catch (e) {
      print('Error updating recipe: $e');
      rethrow;
    }
  }

  // Delete recipe
  Future<void> deleteRecipe(String recipeId) async {
    try {
      if (_currentMachineId == null) return;

      await _recipeRepository.deleteRecipe(_currentMachineId!, recipeId);
      _recipes.removeWhere((recipe) => recipe.id == recipeId);
      _publicRecipes.removeWhere((recipe) => recipe.id == recipeId);
      notifyListeners();
    } catch (e) {
      print('Error deleting recipe: $e');
      rethrow;
    }
  }

  // Get recipe by ID
  Recipe? getRecipeById(String recipeId) {
    try {
      return _recipes.firstWhere((recipe) => recipe.id == recipeId);
    } catch (e) {
      print('Recipe not found: $e');
      return null;
    }
  }

  // Clone recipe
  Future<Recipe?> cloneRecipe(Recipe recipe, String newName) async {
    try {
      if (_currentMachineId == null) return null;

      final newRecipe = await _recipeRepository.cloneRecipe(recipe, newName);
      _recipes.add(newRecipe);
      notifyListeners();
      return newRecipe;
    } catch (e) {
      print('Error cloning recipe: $e');
      return null;
    }
  }

  // Get recipes by user
  Future<List<Recipe>> getUserRecipes() async {
    try {
      String? userId = _authService.currentUser?.uid;
      if (userId == null) return [];

      return await _recipeRepository.getUserRecipes(userId);
    } catch (e) {
      print('Error getting user recipes: $e');
      return [];
    }
  }

  // Compare recipe versions
  Map<String, dynamic> compareRecipeVersions(Recipe oldVersion, Recipe newVersion) {
    Map<String, dynamic> differences = {};

    if (oldVersion.name != newVersion.name) {
      differences['name'] = {'old': oldVersion.name, 'new': newVersion.name};
    }

    if (oldVersion.substrate != newVersion.substrate) {
      differences['substrate'] = {'old': oldVersion.substrate, 'new': newVersion.substrate};
    }

    if (oldVersion.chamberTemperatureSetPoint != newVersion.chamberTemperatureSetPoint) {
      differences['chamberTemperatureSetPoint'] = {
        'old': oldVersion.chamberTemperatureSetPoint,
        'new': newVersion.chamberTemperatureSetPoint
      };
    }

    if (oldVersion.pressureSetPoint != newVersion.pressureSetPoint) {
      differences['pressureSetPoint'] = {'old': oldVersion.pressureSetPoint, 'new': newVersion.pressureSetPoint};
    }

    differences['steps'] = _compareSteps(oldVersion.steps, newVersion.steps);

    return differences;
  }

  List<Map<String, dynamic>> _compareSteps(List<RecipeStep> oldSteps, List<RecipeStep> newSteps) {
    List<Map<String, dynamic>> stepDifferences = [];

    int maxLength = oldSteps.length > newSteps.length ? oldSteps.length : newSteps.length;

    for (int i = 0; i < maxLength; i++) {
      if (i < oldSteps.length && i < newSteps.length) {
        if (oldSteps[i].type != newSteps[i].type || !_areParametersEqual(oldSteps[i].parameters, newSteps[i].parameters)) {
          stepDifferences.add({
            'index': i,
            'old': _stepToString(oldSteps[i]),
            'new': _stepToString(newSteps[i]),
          });
        }
        if (oldSteps[i].type == StepType.loop && newSteps[i].type == StepType.loop) {
          var subStepDifferences = _compareSteps(oldSteps[i].subSteps ?? [], newSteps[i].subSteps ?? []);
          if (subStepDifferences.isNotEmpty) {
            stepDifferences.add({
              'index': i,
              'subSteps': subStepDifferences,
            });
          }
        }
      } else if (i < oldSteps.length) {
        stepDifferences.add({
          'index': i,
          'old': _stepToString(oldSteps[i]),
          'new': null,
        });
      } else {
        stepDifferences.add({
          'index': i,
          'old': null,
          'new': _stepToString(newSteps[i]),
        });
      }
    }

    return stepDifferences;
  }

  bool _areParametersEqual(Map<String, dynamic> params1, Map<String, dynamic> params2) {
    if (params1.length != params2.length) return false;
    return params1.keys.every((key) => params1[key] == params2[key]);
  }

  String _stepToString(RecipeStep step) {
    switch (step.type) {
      case StepType.loop:
        return 'Loop ${step.parameters['iterations']} times' +
            (step.parameters['temperature'] != null ? ' (T: ${step.parameters['temperature']}°C)' : '') +
            (step.parameters['pressure'] != null ? ' (P: ${step.parameters['pressure']} atm)' : '');
      case StepType.valve:
        return '${step.parameters['valveType'] == ValveType.valveA ? 'Valve A' : 'Valve B'} for ${step.parameters['duration']}ms' +
            (step.parameters['gasFlow'] != null ? ' (Flow: ${step.parameters['gasFlow']} sccm)' : '');
      case StepType.purge:
        return 'Purge for ${step.parameters['duration']}ms' +
            (step.parameters['gasFlow'] != null ? ' (Flow: ${step.parameters['gasFlow']} sccm)' : '');
      case StepType.setParameter:
        return 'Set ${step.parameters['component']} ${step.parameters['parameter']} to ${step.parameters['value']}';
      default:
        return 'Unknown Step';
    }
  }
}