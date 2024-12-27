import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/recipe.dart';

class RecipeRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<Recipe>> getMachineRecipes(String machineId) async {
    final snapshot = await _firestore
        .collection('machines')
        .doc(machineId)
        .collection('recipes')
        .get();

    return snapshot.docs.map((doc) => Recipe.fromJson(doc.data())).toList();
  }

  Future<List<Recipe>> getPublicRecipes(String machineId) async {
    final snapshot = await _firestore
        .collection('machines')
        .doc(machineId)
        .collection('recipes')
        .where('isPublic', isEqualTo: true)
        .get();

    return snapshot.docs.map((doc) => Recipe.fromJson(doc.data())).toList();
  }

  Future<void> createRecipe(String machineId, Recipe recipe) async {
    final docRef = _firestore
        .collection('machines')
        .doc(machineId)
        .collection('recipes')
        .doc();

    recipe.id = docRef.id;
    await docRef.set(recipe.toJson());
  }

  Future<void> updateRecipe(String machineId, Recipe recipe) async {
    await _firestore
        .collection('machines')
        .doc(machineId)
        .collection('recipes')
        .doc(recipe.id)
        .update(recipe.toJson());
  }

  Future<void> deleteRecipe(String machineId, String recipeId) async {
    await _firestore
        .collection('machines')
        .doc(machineId)
        .collection('recipes')
        .doc(recipeId)
        .delete();
  }

  Future<void> cloneRecipe(String machineId, Recipe recipe, String newName) async {
    final newRecipe = Recipe(
      id: '',
      name: newName,
      description: recipe.description,
      createdBy: recipe.createdBy,
      createdAt: DateTime.now(),
      machineId: machineId,
      isPublic: false,
      substrate: recipe.substrate,
      chamberTemperatureSetPoint: recipe.chamberTemperatureSetPoint,
      pressureSetPoint: recipe.pressureSetPoint,
      steps: List.from(recipe.steps),
    );

    await createRecipe(machineId, newRecipe);
  }
}