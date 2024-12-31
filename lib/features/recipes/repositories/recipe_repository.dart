import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/recipe.dart';

class RecipeRepository {
  final FirebaseFirestore _firestore;

  RecipeRepository(this._firestore);

  Future<List<Recipe>> getRecipes(String userId) async {
    final snapshot = await _firestore
        .collection('recipes')
        .where('createdBy', isEqualTo: userId)
        .get();

    return snapshot.docs.map((doc) => Recipe.fromFirestore(doc)).toList();
  }

  Future<List<Recipe>> getPublicRecipes() async {
    final snapshot = await _firestore
        .collection('recipes')
        .where('isPublic', isEqualTo: true)
        .get();

    return snapshot.docs.map((doc) => Recipe.fromFirestore(doc)).toList();
  }

  Future<Recipe?> getRecipeById(String userId, String recipeId) async {
    final doc = await _firestore
        .collection('recipes')
        .doc(recipeId)
        .get();

    if (!doc.exists) return null;
    return Recipe.fromFirestore(doc);
  }

  Future<void> createRecipe(String userId, String machineId, Recipe recipe) async {
    await _firestore
        .collection('recipes')
        .doc(recipe.id)
        .set(recipe.toFirestore());
  }

  Future<void> updateRecipe(String userId, Recipe recipe) async {
    await _firestore
        .collection('recipes')
        .doc(recipe.id)
        .update(recipe.toFirestore());
  }

  Future<void> deleteRecipe(String userId, String recipeId) async {
    await _firestore
        .collection('recipes')
        .doc(recipeId)
        .delete();
  }
}
