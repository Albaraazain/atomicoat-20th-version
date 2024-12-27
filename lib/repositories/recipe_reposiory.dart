// lib/repositories/recipe_repository.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import '../modules/system_operation_also_main_module/models/recipe.dart';
import 'base_repository.dart';

class RecipeRepository extends BaseRepository<Recipe> {
  final FirebaseFirestore _firestore;

  RecipeRepository({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance,
      super('recipes', firestore: firestore);

  @override
  Recipe fromJson(Map<String, dynamic> json) => Recipe.fromJson(json);

  // Create a new recipe
  Future<void> createRecipe(Recipe recipe) async {
    final recipeRef = _firestore
        .collection('machines')
        .doc(recipe.machineId)
        .collection('recipes')
        .doc(recipe.id);

    await recipeRef.set(recipe.toJson());
  }

  // Get recipe by ID
  Future<Recipe?> getRecipeById(String machineId, String recipeId) async {
    final doc = await _firestore
        .collection('machines')
        .doc(machineId)
        .collection('recipes')
        .doc(recipeId)
        .get();

    if (doc.exists) {
      final data = doc.data() as Map<String, dynamic>;
      data['id'] = doc.id;
      return Recipe.fromJson(data);
    }
    return null;
  }

  // Get all recipes for a machine
  Future<List<Recipe>> getMachineRecipes(String machineId) async {
    final snapshot = await _firestore
        .collection('machines')
        .doc(machineId)
        .collection('recipes')
        .orderBy('createdAt', descending: true)
        .get();

    return snapshot.docs.map((doc) {
      final data = doc.data();
      data['id'] = doc.id;
      return Recipe.fromJson(data);
    }).toList();
  }

  // Get recipes created by a user
  Future<List<Recipe>> getUserRecipes(String userId) async {
    final recipes = await _firestore
        .collectionGroup('recipes')
        .where('createdBy', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .get();

    return recipes.docs.map((doc) {
      final data = doc.data();
      data['id'] = doc.id;
      return Recipe.fromJson(data);
    }).toList();
  }

  // Get public recipes for a machine
  Future<List<Recipe>> getPublicRecipes(String machineId) async {
    final snapshot = await _firestore
        .collection('machines')
        .doc(machineId)
        .collection('recipes')
        .where('isPublic', isEqualTo: true)
        .orderBy('createdAt', descending: true)
        .get();

    return snapshot.docs.map((doc) {
      final data = doc.data();
      data['id'] = doc.id;
      return Recipe.fromJson(data);
    }).toList();
  }

  // Update recipe
  Future<void> updateRecipe(Recipe recipe) async {
    await _firestore
        .collection('machines')
        .doc(recipe.machineId)
        .collection('recipes')
        .doc(recipe.id)
        .update(recipe.toJson());
  }

  // Delete recipe
  Future<void> deleteRecipe(String machineId, String recipeId) async {
    await _firestore
        .collection('machines')
        .doc(machineId)
        .collection('recipes')
        .doc(recipeId)
        .delete();
  }

  // Clone recipe (create a copy with a new ID)
  Future<Recipe> cloneRecipe(Recipe recipe, String newName) async {
    final newRecipe = Recipe(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: newName,
      steps: List.from(recipe.steps),
      substrate: recipe.substrate,
      createdAt: DateTime.now(),
      machineId: recipe.machineId,
      createdBy: recipe.createdBy,
      chamberTemperatureSetPoint: recipe.chamberTemperatureSetPoint,
      pressureSetPoint: recipe.pressureSetPoint,
      description: '${recipe.description ?? ''} (Cloned)',
      isPublic: false,
    );

    await createRecipe(newRecipe);
    return newRecipe;
  }
}