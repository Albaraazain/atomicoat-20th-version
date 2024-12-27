// lib/modules/system_operation_also_main_module/providers/recipe_provider.dart

import 'package:flutter/foundation.dart';
import '../models/recipe.dart';
import '../../../services/auth_service.dart';
import '../repositories/recipe_repository.dart';

class RecipeProvider with ChangeNotifier {
  final RecipeRepository _recipeRepository;
  final AuthService _authService;
  String? currentMachineId;
  List<Recipe> _recipes = [];
  List<Recipe> _publicRecipes = [];

  RecipeProvider(this._recipeRepository, this._authService);

  List<Recipe> get recipes => _recipes;
  List<Recipe> get publicRecipes => _publicRecipes;
  String? get currentUserId => _authService.currentUser?.uid;

  Future<void> setCurrentMachine(String machineId) async {
    currentMachineId = machineId;
    await loadRecipes();
  }

  Future<void> loadRecipes() async {
    if (currentMachineId == null) return;

    final userId = currentUserId;
    if (userId == null) return;

    _recipes = await _recipeRepository.getMachineRecipes(currentMachineId!);
    _publicRecipes = await _recipeRepository.getPublicRecipes(currentMachineId!);
    notifyListeners();
  }

  Future<void> createRecipe(Recipe recipe) async {
    if (currentMachineId == null) return;
    await _recipeRepository.createRecipe(currentMachineId!, recipe);
    await loadRecipes();
  }

  Future<void> updateRecipe(Recipe recipe) async {
    if (currentMachineId == null) return;
    await _recipeRepository.updateRecipe(currentMachineId!, recipe);
    await loadRecipes();
  }

  Future<void> deleteRecipe(String recipeId) async {
    if (currentMachineId == null) return;
    await _recipeRepository.deleteRecipe(currentMachineId!, recipeId);
    await loadRecipes();
  }

  Future<void> cloneRecipe(Recipe recipe, String newName) async {
    if (currentMachineId == null) return;
    await _recipeRepository.cloneRecipe(currentMachineId!, recipe, newName);
    await loadRecipes();
  }
}