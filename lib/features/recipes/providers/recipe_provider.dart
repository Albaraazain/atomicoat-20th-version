import 'package:flutter/foundation.dart';
import '../models/recipe.dart';
import '../../../core/auth/services/auth_service.dart';
import '../repositories/recipe_repository.dart';

class RecipeProvider with ChangeNotifier {
  final RecipeRepository _recipeRepository;
  final AuthService _authService;
  String? _currentMachineId;
  final List<Recipe> _recipes = [];
  final List<Recipe> _publicRecipes = [];

  String? get currentUserId => _authService.currentUser?.uid;
  String? get currentMachineId => _currentMachineId;
  List<Recipe> get publicRecipes => List.unmodifiable(_publicRecipes);
  List<Recipe> get recipes => List.unmodifiable(_recipes);

  Recipe? _activeRecipe;
  Recipe? get activeRecipe => _activeRecipe;

  int _currentRecipeStepIndex = 0;
  int get currentRecipeStepIndex => _currentRecipeStepIndex;

  Recipe? _selectedRecipe;
  Recipe? get selectedRecipe => _selectedRecipe;

  RecipeProvider(this._recipeRepository, this._authService);

  void setCurrentMachineId(String? machineId) {
    _currentMachineId = machineId;
    notifyListeners();
  }

  Future<void> loadRecipes() async {
    if (currentUserId == null) return;

    _recipes.clear();
    _publicRecipes.clear();

    final recipes = await _recipeRepository.getRecipes(currentUserId!);
    final publicRecipes = await _recipeRepository.getPublicRecipes();

    _recipes.addAll(recipes);
    _publicRecipes.addAll(publicRecipes);
    notifyListeners();
  }

  Future<void> createRecipe(Recipe recipe) async {
    if (currentUserId == null || currentMachineId == null) return;

    await _recipeRepository.createRecipe(
      currentUserId!,
      currentMachineId!,
      recipe
    );
    await loadRecipes();
  }

  Future<void> updateRecipe(Recipe recipe) async {
    if (currentUserId == null) return;

    await _recipeRepository.updateRecipe(
      currentUserId!,
      recipe
    );
    await loadRecipes();
  }

  Future<void> deleteRecipe(String recipeId) async {
    if (currentUserId == null) return;

    await _recipeRepository.deleteRecipe(
      currentUserId!,
      recipeId
    );
    await loadRecipes();
  }

  Future<void> cloneRecipe(String recipeId, String newName) async {
    if (currentUserId == null || currentMachineId == null) return;

    final recipe = await _recipeRepository.getRecipeById(
      currentUserId!,
      recipeId
    );

    if (recipe != null) {
      final clonedRecipe = recipe.copyWith(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: newName,
        isPublic: false
      );
      await createRecipe(clonedRecipe);
    }
  }

  Future<Recipe?> getRecipeById(String id) async {
    return _recipes.firstWhere((recipe) => recipe.id == id);
  }

  Future<void> executeRecipe(Recipe recipe) async {
    _activeRecipe = recipe;
    _currentRecipeStepIndex = 0;
    notifyListeners();
  }

  void selectRecipe(String id) {
    _selectedRecipe = _recipes.firstWhere((recipe) => recipe.id == id);
    notifyListeners();
  }

  void incrementRecipeStepIndex() {
    if (_activeRecipe != null &&
        _currentRecipeStepIndex < _activeRecipe!.steps.length - 1) {
      _currentRecipeStepIndex++;
      notifyListeners();
    }
  }

  void completeRecipe() {
    _activeRecipe = null;
    _currentRecipeStepIndex = 0;
    notifyListeners();
  }
}
