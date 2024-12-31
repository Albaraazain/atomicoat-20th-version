import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/recipe.dart';
import '../providers/recipe_provider.dart';
import 'recipe_detail_screen.dart';

class RecipeManagementScreen extends StatefulWidget {
  @override
  _RecipeManagementScreenState createState() => _RecipeManagementScreenState();
}

class _RecipeManagementScreenState extends State<RecipeManagementScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<RecipeProvider>(
      builder: (context, recipeProvider, child) {
        if (recipeProvider.currentMachineId == null) {
          return Scaffold(
            appBar: AppBar(title: Text('Recipe Management')),
            body: Center(child: Text('Please select a machine first')),
          );
        }

        return Scaffold(
          appBar: AppBar(
            leading: IconButton(
              icon: Icon(Icons.menu),
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
            ),
            title: Text(
              'Recipe Management',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            bottom: TabBar(
              controller: _tabController,
              tabs: [
                Tab(text: 'My Recipes'),
                Tab(text: 'Public Recipes'),
              ],
            ),
            actions: [
              IconButton(
                icon: Icon(Icons.add, size: 28),
                onPressed: () => _navigateToRecipeDetail(context),
              ),
            ],
          ),
          body: TabBarView(
            controller: _tabController,
            children: [
              _buildRecipeList(context, recipeProvider.recipes, recipeProvider, true),
              _buildRecipeList(context, recipeProvider.publicRecipes, recipeProvider, false),
            ],
          ),
        );
      },
    );
  }

  Widget _buildRecipeList(BuildContext context, List<Recipe> recipes, RecipeProvider provider, bool isMyRecipes) {
    if (recipes.isEmpty) {
      return Center(
        child: Text(
          isMyRecipes ? 'No recipes yet. Create one!' : 'No public recipes available.',
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(8.0),
      itemCount: recipes.length,
      itemBuilder: (context, index) {
        final recipe = recipes[index];
        return Card(
          elevation: 2,
          margin: EdgeInsets.symmetric(vertical: 8),
          child: ListTile(
            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            title: Text(
              recipe.name,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  recipe.description ?? 'No description',
                  style: TextStyle(fontSize: 14),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.person, size: 16),
                    SizedBox(width: 4),
                    Text(recipe.createdBy),
                    SizedBox(width: 16),
                    Icon(Icons.access_time, size: 16),
                    SizedBox(width: 4),
                    Text(_formatDate(recipe.createdAt)),
                  ],
                ),
              ],
            ),
            trailing: isMyRecipes && recipe.createdBy == provider.currentUserId
                ? Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(Icons.edit, color: Colors.blue),
                        onPressed: () => _navigateToRecipeDetail(context, recipeId: recipe.id),
                      ),
                      IconButton(
                        icon: Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _confirmDeleteRecipe(context, provider, recipe.id, recipe.name),
                      ),
                    ],
                  )
                : IconButton(
                    icon: Icon(Icons.copy, color: Colors.blue),
                      onPressed: () => _cloneRecipe(context, provider, recipe.id, recipe.name),
                  ),
            onTap: () => _showRecipeDetails(context, recipe),
          ),
        );
      },
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  void _navigateToRecipeDetail(BuildContext context, {String? recipeId}) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RecipeDetailScreen(recipeId: recipeId),
      ),
    );

    if (result == true) {
      Provider.of<RecipeProvider>(context, listen: false).loadRecipes();
    }
  }

  void _confirmDeleteRecipe(BuildContext context, RecipeProvider provider, String recipeId, String recipeName) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirm Delete'),
          content: Text('Are you sure you want to delete "$recipeName"?'),
          actions: [
            TextButton(
              child: Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: Text('Delete', style: TextStyle(color: Colors.red)),
              onPressed: () {
                provider.deleteRecipe(recipeId);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _cloneRecipe(BuildContext context, RecipeProvider provider, String recipeId, String recipeName) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        final nameController = TextEditingController(text: '$recipeName (Copy)');
        return AlertDialog(
          title: Text('Clone Recipe'),
          content: TextField(
            controller: nameController,
            decoration: InputDecoration(labelText: 'New Recipe Name'),
          ),
          actions: [
            TextButton(
              child: Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: Text('Clone'),
              onPressed: () async {
                await provider.cloneRecipe(recipeId, nameController.text);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _showRecipeDetails(BuildContext context, Recipe recipe) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(recipe.name),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (recipe.description != null) ...[
                  Text('Description:', style: TextStyle(fontWeight: FontWeight.bold)),
                  Text(recipe.description!),
                  SizedBox(height: 16),
                ],
                Text('Substrate: ${recipe.substrate}'),
                Text('Temperature: ${recipe.chamberTemperatureSetPoint}°C'),
                Text('Pressure: ${recipe.pressureSetPoint} atm'),
                SizedBox(height: 16),
                Text('Steps:', style: TextStyle(fontWeight: FontWeight.bold)),
                ...recipe.steps.map((step) => Padding(
                  padding: EdgeInsets.only(left: 16, top: 4),
                  child: Text('• ${_getStepDescription(step)}'),
                )).toList(),
              ],
            ),
          ),
          actions: [
            TextButton(
              child: Text('Close'),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        );
      },
    );
  }

  String _getStepDescription(RecipeStep step) {
    switch (step.type) {
      case StepType.valve:
        return 'Open ${step.parameters['valveType']} for ${step.parameters['duration']}s';
      case StepType.purge:
        return 'Purge for ${step.parameters['duration']}ms';
      case StepType.loop:
        return 'Loop ${step.parameters['iterations']} times';
      case StepType.setParameter:
        return 'Set ${step.parameters['parameter']} of ${step.parameters['component']} to ${step.parameters['value']}';
      default:
        return 'Unknown step';
    }
  }
}
