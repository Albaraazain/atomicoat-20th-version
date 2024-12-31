import 'package:flutter/material.dart';
import '../../features/machines/screens/machine_list_screen.dart';
import '../../features/machines/screens/machine_creation_screen.dart';
import '../../features/machines/screens/machine_details_screen.dart';
import '../../features/machines/screens/machine_edit_screen.dart';
import '../../features/dashboard/screens/machine_dashboard_screen.dart';
import '../../features/process/screens/process_list_screen.dart';
import '../../features/process/screens/process_details_screen.dart';
import '../../features/process/screens/process_monitoring_screen.dart';
import '../../features/experiments/screens/experiment_list_screen.dart';
import '../../features/experiments/screens/experiment_details_screen.dart';
import '../../features/recipes/screens/recipe_list_screen.dart';
import '../../features/recipes/screens/recipe_details_screen.dart';
import '../../features/recipes/screens/recipe_creation_screen.dart';
import '../../core/auth/screens/login_screen.dart';

class RouteConfig {
  // Auth routes
  static const String loginRoute = '/login';
  static const String registrationRoute = '/register';

  // Dashboard routes
  static const String mainDashboardRoute = '/dashboard';
  static const String adminDashboardRoute = '/admin';

  // Machine routes
  static const String machineListRoute = '/machines';
  static const String machineCreateRoute = '/machines/create';
  static const String machineDetailsRoute = '/machines/details';
  static const String machineEditRoute = '/machines/edit';

  // Process routes
  static const String processListRoute = '/processes';
  static const String processDetailsRoute = '/processes/details';
  static const String processMonitoringRoute = '/processes/monitor';

  // Experiment routes
  static const String experimentListRoute = '/experiments';
  static const String experimentDetailsRoute = '/experiments/details';

  // Recipe routes
  static const String recipeListRoute = '/recipes';
  static const String recipeDetailsRoute = '/recipes/details';
  static const String recipeCreateRoute = '/recipes/create';

  static Map<String, Widget Function(BuildContext)> routes = {
    loginRoute: (context) => LoginScreen(),
    mainDashboardRoute: (context) => MachineDashboard(),
    machineListRoute: (context) => MachineListScreen(),
    machineCreateRoute: (context) => MachineCreationScreen(),
    processListRoute: (context) => ProcessListScreen(),
    experimentListRoute: (context) => ExperimentListScreen(),
    recipeListRoute: (context) => RecipeListScreen(),
    recipeCreateRoute: (context) => RecipeCreationScreen(),
  };

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case machineDetailsRoute:
        final machineId = settings.arguments as String;
        return MaterialPageRoute(
          builder: (context) => MachineDetailsScreen(machineId: machineId),
        );

      case machineEditRoute:
        final machineId = settings.arguments as String;
        return MaterialPageRoute(
          builder: (context) => MachineEditScreen(machineId: machineId),
        );

      case processDetailsRoute:
        final processId = settings.arguments as String;
        return MaterialPageRoute(
          builder: (context) => ProcessDetailsScreen(processId: processId),
        );

      case processMonitoringRoute:
        final processId = settings.arguments as String;
        return MaterialPageRoute(
          builder: (context) => ProcessMonitoringScreen(processId: processId),
        );

      case experimentDetailsRoute:
        final experimentId = settings.arguments as String;
        return MaterialPageRoute(
          builder: (context) => ExperimentDetailsScreen(experimentId: experimentId),
        );

      case recipeDetailsRoute:
        final recipeId = settings.arguments as String;
        return MaterialPageRoute(
          builder: (context) => RecipeDetailsScreen(recipeId: recipeId),
        );

      default:
        return MaterialPageRoute(
          builder: (context) => Scaffold(
            body: Center(
              child: Text('Route ${settings.name} not found'),
            ),
          ),
        );
    }
  }
}