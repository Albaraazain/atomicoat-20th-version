// lib/config/provider_config.dart

import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// Services
import '../services/auth_service.dart';
import '../services/navigation_service.dart';

// Repositories
import '../repositories/system_state_repository.dart';
import '../features/alarm/repository/alarm_repository.dart';

// Providers
import '../providers/auth_provider.dart';
import '../modules/system_operation_also_main_module/providers/component_management_provider.dart';
import '../modules/system_operation_also_main_module/providers/component_status_provider.dart';
import '../modules/system_operation_also_main_module/providers/component_values_provider.dart';
import '../modules/system_operation_also_main_module/providers/recipe_provider.dart';
import '../modules/system_operation_also_main_module/providers/safety_error_provider.dart';
import '../modules/system_operation_also_main_module/providers/system_state_provider.dart';

// BLoCs
import '../features/alarm/bloc/alarm_bloc.dart';

class ProviderConfig {
  static List<SingleChildWidget> get providers => [
    // Core Services
    Provider<NavigationService>(
      create: (_) => NavigationService(),
    ),

    Provider<AuthService>(
      create: (_) => AuthService(),
    ),

    // Repositories
    Provider<SystemStateRepository>(
      create: (_) => SystemStateRepository(),
    ),

    Provider<AlarmRepository>(
      create: (_) => AlarmRepository(),
    ),

    // Authentication
    ChangeNotifierProvider(
      create: (context) => AuthProvider(
        context.read<AuthService>(),
      ),
    ),

    // Create AlarmBloc FIRST before other providers that depend on it
    BlocProvider<AlarmBloc>(
      create: (context) => AlarmBloc(
        context.read<AlarmRepository>(),
        context.read<AuthService>().currentUserId,
      ),
    ),

    // Component Management Layer
    ChangeNotifierProvider<ComponentManagementProvider>(
      create: (_) => ComponentManagementProvider(),
    ),

    // Component Status Layer
    ChangeNotifierProvider<ComponentStatusProvider>(
      create: (_) => ComponentStatusProvider(),
    ),

    // Component Values Layer
    ChangeNotifierProxyProvider2<ComponentManagementProvider, ComponentStatusProvider, ComponentValuesProvider>(
      create: (_) => ComponentValuesProvider(),
      update: (_, management, status, previous) {
        return previous ?? ComponentValuesProvider();
      },
    ),

    // Recipe Management
    ChangeNotifierProvider<RecipeProvider>(
      create: (context) => RecipeProvider(
        context.read<AuthService>(),
      ),
    ),

    // Safety Error Management
    ChangeNotifierProvider<SafetyErrorProvider>(
      create: (context) => SafetyErrorProvider(
        context.read<AuthService>(),
      ),
    ),

    // System State Management (Now AlarmBloc will be available)
    ChangeNotifierProxyProvider5<
        ComponentManagementProvider,
        ComponentStatusProvider,
        ComponentValuesProvider,
        RecipeProvider,
        AlarmBloc,
        SystemStateProvider>(
      create: (context) => SystemStateProvider(
        context.read<ComponentManagementProvider>(),
        context.read<ComponentStatusProvider>(),
        context.read<ComponentValuesProvider>(),
        context.read<RecipeProvider>(),
        context.read<AlarmBloc>(),
        context.read<SystemStateRepository>(),
        context.read<AuthService>(),
      ),
      update: (_, management, status, values, recipe, alarmBloc, previous) {
        if (previous == null) {
          return SystemStateProvider(
            management,
            status,
            values,
            recipe,
            alarmBloc,
            _.read<SystemStateRepository>(),
            _.read<AuthService>(),
          );
        }
        previous.updateProviders(recipe);
        return previous;
      },
    ),
  ];
}