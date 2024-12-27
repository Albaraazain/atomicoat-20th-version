// lib/providers/system_state_provider.dart

import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:experiment_planner/features/alarm/bloc/alarm_bloc.dart';
import 'package:experiment_planner/features/alarm/bloc/alarm_event.dart';
import 'package:experiment_planner/features/alarm/bloc/alarm_state.dart';
import 'package:flutter/foundation.dart';
import '../../../repositories/system_state_repository.dart';
import '../../../services/auth_service.dart';
import '../models/data_point.dart';
import '../models/recipe.dart';
import '../../../features/alarm/models/alarm.dart';
import '../models/system_component.dart';
import '../models/system_log_entry.dart';
import '../models/safety_error.dart';
import '../services/ald_system_simulation_service.dart';
import 'recipe_provider.dart';
import 'component_management_provider.dart';
import 'component_status_provider.dart';
import 'component_values_provider.dart';

class SystemStateProvider with ChangeNotifier {
  String? _currentMachineId;
  final ComponentManagementProvider _componentManager;
  final ComponentStatusProvider _componentStatus;
  final ComponentValuesProvider _componentValues;
  final SystemStateRepository _systemStateRepository;
  final AuthService _authService;
  final AlarmBloc _alarmBloc;  // Changed from AlarmProvider
  Recipe? _activeRecipe;
  int _currentRecipeStepIndex = 0;
  Recipe? _selectedRecipe;
  bool _isSystemRunning = false;
  final List<SystemLogEntry> _systemLog = [];
  late AldSystemSimulationService _simulationService;
  late RecipeProvider _recipeProvider;
  Timer? _stateUpdateTimer;

  // Add a constant for the maximum number of log entries to keep
  static const int MAX_LOG_ENTRIES = 1000;

  // Add a constant for the maximum number of data points per parameter
  static const int MAX_DATA_POINTS_PER_PARAMETER = 1000;

  SystemStateProvider(
    this._componentManager,
    this._componentStatus,
    this._componentValues,
    this._recipeProvider,
    this._alarmBloc,  // Changed from AlarmProvider to AlarmBloc
    this._systemStateRepository,
    this._authService,
  ) {
    _initializeComponents();
    _loadSystemLog();
    _simulationService = AldSystemSimulationService(systemStateProvider: this);
  }

  // Getters
  Recipe? get activeRecipe => _activeRecipe;
  int get currentRecipeStepIndex => _currentRecipeStepIndex;
  Recipe? get selectedRecipe => _selectedRecipe;
  bool get isSystemRunning => _isSystemRunning;
  List<SystemLogEntry> get systemLog => List.unmodifiable(_systemLog);
  List<Alarm> get activeAlarms {
    final state = _alarmBloc.state;
    return state is AlarmLoadSuccess ? state.activeAlarms : [];
  }

  Map<String, SystemComponent> get components => _componentManager.components;

  // Initialize all system components with their parameters
  void _initializeComponents() {
    _componentManager.initializeDefaultComponents();
  }

  // Load system log from repository
  Future<void> _loadSystemLog() async {
    String? userId = _authService.currentUser?.uid;
    if (userId != null) {
      final logs = await _systemStateRepository.getSystemLog(userId);
      _systemLog.addAll(logs.take(MAX_LOG_ENTRIES));
      if (_systemLog.length > MAX_LOG_ENTRIES) {
        _systemLog.removeRange(0, _systemLog.length - MAX_LOG_ENTRIES);
      }
      notifyListeners();
    }
  }

  List<String> getSystemIssues() {
    List<String> issues = [];

    // Check Nitrogen Flow
    final nitrogenGenerator = _componentManager.getComponent('Nitrogen Generator');
    if (nitrogenGenerator != null) {
      if (!nitrogenGenerator.isActivated) {
        issues.add('Nitrogen Generator is not activated');
      } else if (nitrogenGenerator.currentValues['flow_rate']! < 10.0) {
        issues.add(
            'Nitrogen flow rate is too low (current: ${nitrogenGenerator.currentValues['flow_rate']!.toStringAsFixed(1)}, required: ≥10.0)');
      }
    }

    // Check MFC
    final mfc = _componentManager.getComponent('MFC');
    if (mfc != null) {
      if (!mfc.isActivated) {
        issues.add('MFC is not activated');
      } else if (mfc.currentValues['flow_rate']! != 20.0) {
        issues.add(
            'MFC flow rate needs adjustment (current: ${mfc.currentValues['flow_rate']!.toStringAsFixed(1)}, required: 20.0)');
      }
    }

    // Check Pressure
    final pressureControlSystem = _componentManager.getComponent('Pressure Control System');
    if (pressureControlSystem != null) {
      if (!pressureControlSystem.isActivated) {
        issues.add('Pressure Control System is not activated');
      } else if (pressureControlSystem.currentValues['pressure']! >= 760.0) {
        issues.add(
            'Pressure is too high (current: ${pressureControlSystem.currentValues['pressure']!.toStringAsFixed(1)}, must be <760.0)');
      }
    }

    // Check Pump
    final pump = _componentManager.getComponent('Vacuum Pump');
    if (pump != null) {
      if (!pump.isActivated) {
        issues.add('Vacuum Pump is not activated');
      }
    }

    // Check Heaters
    final heaters = [
      'Precursor Heater 1',
      'Precursor Heater 2',
      'Frontline Heater',
      'Backline Heater'
    ];
    for (var heaterName in heaters) {
      final heater = _componentManager.getComponent(heaterName);
      if (heater != null && !heater.isActivated) {
        issues.add('$heaterName is not activated');
      }
    }

    // Check value mismatches
    for (var component in _componentManager.components.values) {
      for (var entry in component.currentValues.entries) {
        final setValue = component.setValues[entry.key] ?? 0.0;
        if (setValue != entry.value) {
          issues.add(
              '${component.name}: ${entry.key} mismatch (current: ${entry.value.toStringAsFixed(1)}, set: ${setValue.toStringAsFixed(1)})');
        }
      }
    }

    return issues;
  }

  void batchUpdateComponentValues(Map<String, Map<String, double>> updates) {
    updates.forEach((componentName, newStates) {
      final component = _componentManager.getComponent(componentName);
      if (component != null) {
        component.updateCurrentValues(newStates);
      }
    });
    notifyListeners();
  }

  bool checkSystemReadiness() {
    return _componentStatus.checkSystemReadiness();
  }

  // Add a log entry
  void addLogEntry(String message, ComponentStatus status) {
    String? userId = _authService.currentUser?.uid;
    if (userId == null) return;

    SystemLogEntry logEntry = SystemLogEntry(
      timestamp: DateTime.now(),
      message: message,
      severity: status,
    );
    _systemLog.add(logEntry);
    if (_systemLog.length > MAX_LOG_ENTRIES) {
      _systemLog.removeAt(0);
    }
    _systemStateRepository.addLogEntry(userId, logEntry);
    notifyListeners();
  }

  // Retrieve a component by name
  SystemComponent? getComponentByName(String componentName) {
    return _componentManager.getComponent(componentName);
  }

  // Start the simulation
  void startSimulation() {
    if (!_isSystemRunning) {
      _isSystemRunning = true;
      _simulationService.startSimulation();
      addLogEntry('Simulation started', ComponentStatus.normal);
      notifyListeners();
    }
  }

  // Stop the simulation
  void stopSimulation() {
    if (_isSystemRunning) {
      _isSystemRunning = false;
      _simulationService.stopSimulation();
      addLogEntry('Simulation stopped', ComponentStatus.normal);
      notifyListeners();
    }
  }

  // Toggle simulation state
  void toggleSimulation() {
    if (_isSystemRunning) {
      stopSimulation();
    } else {
      startSimulation();
    }
  }

  /// Fetch historical data for a specific component and update the `parameterHistory`
  Future<void> fetchComponentHistory(String componentName) async {
    String? userId = _authService.currentUser?.uid;
    if (userId == null) return;

    final now = DateTime.now();
    final start = now.subtract(Duration(hours: 24));

    try {
      List<Map<String, dynamic>> historyData =
          await _systemStateRepository.getComponentHistory(
        userId,
        componentName,
        start,
        now,
      );

      final component = _componentManager.getComponent(componentName);
      if (component != null) {
        // Parse historical data and populate the parameterHistory
        for (var data in historyData.take(MAX_DATA_POINTS_PER_PARAMETER)) {
          final timestamp = (data['timestamp'] as Timestamp).toDate();
          final currentValues = Map<String, double>.from(data['currentValues']);

          currentValues.forEach((parameter, value) {
            component.updateCurrentValues({parameter: value});
            _componentManager.addParameterDataPoint(
              componentName,
              parameter,
              DataPoint(timestamp: timestamp, value: value),
              maxDataPoints: MAX_DATA_POINTS_PER_PARAMETER,
            );
          });
        }
      }
    } catch (e) {
      print("Error fetching component history for $componentName: $e");
    }
  }

  // Start the system
  void startSystem() {
    if (!_isSystemRunning && checkSystemReadiness()) {
      _isSystemRunning = true;
      _simulationService.startSimulation();
      _startContinuousStateLogging();
      addLogEntry('System started', ComponentStatus.normal);
      notifyListeners();
    } else {
      addAlarm('System not ready to start. Check system readiness.', AlarmSeverity.warning);
    }
  }

  bool validateSetVsMonitoredValues() {
    bool isValid = true;
    final tolerance = 0.1; // 10% tolerance

    for (var component in _componentManager.components.values) {
      for (var entry in component.currentValues.entries) {
        final setValue = component.setValues[entry.key] ?? 0.0;
        final currentValue = entry.value;

        // Skip validation for certain parameters
        if (entry.key == 'status') continue;

        // Check if the current value is within tolerance of set value
        if (setValue == 0.0) {
          if (currentValue > tolerance) {
            isValid = false;
            addLogEntry(
                'Mismatch in ${component.name}: ${entry.key} should be near zero',
                ComponentStatus.warning);
          }
        } else {
          final percentDiff = (currentValue - setValue).abs() / setValue;
          if (percentDiff > tolerance) {
            isValid = false;
            addLogEntry(
                'Mismatch in ${component.name}: ${entry.key} is outside tolerance range',
                ComponentStatus.warning);
          }
        }
      }
    }
    return isValid;
  }

  // Stop the system
  void stopSystem() {
    _isSystemRunning = false;
    _activeRecipe = null;
    _currentRecipeStepIndex = 0;
    _simulationService.stopSimulation();
    _stopContinuousStateLogging();
    _deactivateAllValves();
    addLogEntry('System stopped', ComponentStatus.normal);
    notifyListeners();
  }

  // Start continuous state logging
  void _startContinuousStateLogging() {
    _stateUpdateTimer = Timer.periodic(Duration(seconds: 5), (_) {
      _saveCurrentState();
    });
  }

  // Stop continuous state logging
  void _stopContinuousStateLogging() {
    _stateUpdateTimer?.cancel();
    _stateUpdateTimer = null;
  }

  // Save current state to repository
  void _saveCurrentState() {
    String? userId = _authService.currentUser?.uid;
    if (userId == null) return;

    for (var component in _componentManager.components.values) {
      _systemStateRepository.saveComponentState(userId, component);
    }
    _systemStateRepository.saveSystemState(userId, {
      'isRunning': _isSystemRunning,
      'activeRecipeId': _activeRecipe?.id,
      'currentRecipeStepIndex': _currentRecipeStepIndex,
    });
  }

  // Log a parameter value
  void logParameterValue(String componentName, String parameter, double value) {
    _componentManager.addParameterDataPoint(componentName, parameter,
        DataPoint.reducedPrecision(timestamp: DateTime.now(), value: value));
  }

  // Run diagnostic on a component
  void runDiagnostic(String componentName) {
    final component = _componentManager.getComponent(componentName);
    if (component != null) {
      addLogEntry(
          'Running diagnostic for ${component.name}', ComponentStatus.normal);
      Future.delayed(const Duration(seconds: 2), () {
        addLogEntry(
            '${component.name} diagnostic completed: All systems nominal',
            ComponentStatus.normal);
        notifyListeners();
      });
    }
  }

  // Update providers if needed
  void updateProviders(
      RecipeProvider recipeProvider) {
    if (_recipeProvider != recipeProvider) {
      _recipeProvider = recipeProvider;
    }
    notifyListeners();
  }

  // Check if system is ready for a recipe
  bool isSystemReadyForRecipe() {
    return checkSystemReadiness() && validateSetVsMonitoredValues();
  }

  // Execute a recipe
  Future<void> executeRecipe(Recipe recipe) async {
    print("Executing recipe: ${recipe.name}");
    if (isSystemReadyForRecipe()) {
      _activeRecipe = recipe;
      _currentRecipeStepIndex = 0;
      _isSystemRunning = true;
      addLogEntry('Executing recipe: ${recipe.name}', ComponentStatus.normal);
      _simulationService.startSimulation();
      notifyListeners();
      await _executeSteps(recipe.steps);
      completeRecipe();
    } else {
      addAlarm('System not ready to start', AlarmSeverity.warning);
    }
  }

  // Select a recipe
  void selectRecipe(String id) {
    _selectedRecipe = _recipeProvider.getRecipeById(id);
    if (_selectedRecipe != null) {
      addLogEntry(
          'Recipe selected: ${_selectedRecipe!.name}', ComponentStatus.normal);
    } else {
      addAlarm('Failed to select recipe: Recipe not found', AlarmSeverity.warning);
    }
    notifyListeners();
  }

  // Emergency stop
  void emergencyStop() {
    String? userId = _authService.currentUserId;
    if (userId == null) return;

    stopSystem();
    for (var component in _componentManager.components.values) {
      if (component.isActivated) {
        _componentManager.deactivateComponent(component.name);
        _systemStateRepository.saveComponentState(userId, component);
      }
    }

    final alarm = Alarm(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      message: 'Emergency stop activated',
      severity: AlarmSeverity.critical,
      timestamp: DateTime.now(),
    );

    _alarmBloc.add(AddAlarmEvent(alarm, userId));
    addLogEntry('Emergency stop activated', ComponentStatus.error);
    notifyListeners();
  }

  // Check reactor pressure
  bool isReactorPressureNormal() {
    final pressure = _componentManager
            .getComponent('Reaction Chamber')
            ?.currentValues['pressure'] ??
        0.0;
    return pressure >= 0.9 && pressure <= 1.1;
  }

  // Check reactor temperature
  bool isReactorTemperatureNormal() {
    final temperature = _componentManager
            .getComponent('Reaction Chamber')
            ?.currentValues['temperature'] ??
        0.0;
    return temperature >= 145 && temperature <= 155;
  }

  // Check precursor temperature
  bool isPrecursorTemperatureNormal(String precursor) {
    final component = _componentManager.getComponent(precursor);
    if (component != null) {
      final temperature = component.currentValues['temperature'] ?? 0.0;
      return temperature >= 28 && temperature <= 32;
    }
    return false;
  }

  // Increment recipe step index
  void incrementRecipeStepIndex() {
    if (_activeRecipe != null &&
        _currentRecipeStepIndex < _activeRecipe!.steps.length - 1) {
      _currentRecipeStepIndex++;
      notifyListeners();
    }
  }

  // Complete the recipe
  void completeRecipe() {
    addLogEntry(
        'Recipe completed: ${_activeRecipe?.name}', ComponentStatus.normal);
    _activeRecipe = null;
    _currentRecipeStepIndex = 0;
    _isSystemRunning = false;
    _simulationService.stopSimulation();
    notifyListeners();
  }

  // Trigger safety alert
  void triggerSafetyAlert(SafetyError error) {
    String? userId = _authService.currentUserId;
    if (userId == null) return;

    final alarm = Alarm(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      message: error.description,
      severity: _mapSeverityToAlarmSeverity(error.severity),
      timestamp: DateTime.now(),
    );

    _alarmBloc.add(AddAlarmEvent(alarm, userId));
    addLogEntry('Safety Alert: ${error.description}',
        _mapSeverityToComponentStatus(error.severity));
  }

  // Map safety severity to alarm severity
  AlarmSeverity _mapSeverityToAlarmSeverity(SafetyErrorSeverity severity) {
    switch (severity) {
      case SafetyErrorSeverity.warning:
        return AlarmSeverity.warning;
      case SafetyErrorSeverity.critical:
        return AlarmSeverity.critical;
      case SafetyErrorSeverity.info:
        return AlarmSeverity.info;
      case SafetyErrorSeverity.error:
        return AlarmSeverity.critical;
    }
  }

  // Map safety severity to component status
  ComponentStatus _mapSeverityToComponentStatus(SafetyErrorSeverity severity) {
    switch (severity) {
      case SafetyErrorSeverity.warning:
        return ComponentStatus.warning;
      case SafetyErrorSeverity.critical:
        return ComponentStatus.error;
      case SafetyErrorSeverity.info:
        return ComponentStatus.normal;
      case SafetyErrorSeverity.error:
        return ComponentStatus.error;
    }
  }

  // Get all recipes
  List<Recipe> getAllRecipes() {
    return _recipeProvider.recipes;
  }

  // Refresh recipes
  void refreshRecipes() {
    _recipeProvider.loadRecipes();
    notifyListeners();
  }

  // Execute multiple steps
  Future<void> _executeSteps(List<RecipeStep> steps,
      {double? inheritedTemperature, double? inheritedPressure}) async {
    for (var step in steps) {
      if (!_isSystemRunning) break;
      await _executeStep(step,
          inheritedTemperature: inheritedTemperature,
          inheritedPressure: inheritedPressure);
      incrementRecipeStepIndex();
    }
  }

  // Execute a single step
  Future<void> _executeStep(RecipeStep step,
      {double? inheritedTemperature, double? inheritedPressure}) async {
    try {  // Fix: Add error handling
      addLogEntry(
          'Executing step: ${_getStepDescription(step)}', ComponentStatus.normal);
      switch (step.type) {
        case StepType.valve:
          await _executeValveStep(step);
          break;
        case StepType.purge:
          await _executePurgeStep(step);
          break;
        case StepType.loop:
          await _executeLoopStep(step, inheritedTemperature, inheritedPressure);
          break;
        case StepType.setParameter:
          await _executeSetParameterStep(step);
          break;
      }
    } catch (e) {
      addLogEntry('Error executing step: ${e.toString()}', ComponentStatus.error);
      addAlarm('Recipe execution error: ${e.toString()}', AlarmSeverity.critical);
      stopSystem();
    }
  }

  // Deactivate all valves
  void _deactivateAllValves() {
    _componentManager.components.keys
        .where((name) => name.toLowerCase().contains('valve'))
        .forEach((valveName) {
      _componentStatus.deactivateComponent(valveName);
      addLogEntry('$valveName deactivated', ComponentStatus.normal);
    });
  }

  // Get step description
  String _getStepDescription(RecipeStep step) {
    switch (step.type) {
      case StepType.valve:
        return 'Open ${step.parameters['valveType']} for ${step.parameters['duration']} ms';
      case StepType.purge:
        return 'Purge for ${step.parameters['duration']} ms';
      case StepType.loop:
        return 'Loop ${step.parameters['iterations']} times';
      case StepType.setParameter:
        return 'Set ${step.parameters['parameter']} of ${step.parameters['component']} to ${step.parameters['value']}';
      default:
        return 'Unknown step type';
    }
  }

  // Execute a valve step
  Future<void> _executeValveStep(RecipeStep step) async {
    ValveType valveType = step.parameters['valveType'] as ValveType;
    int duration = step.parameters['duration'] as int;
    String valveName = valveType == ValveType.valveA ? 'Valve 1' : 'Valve 2';

    _componentValues.updateComponentCurrentValues(valveName, {'status': 1.0});
    addLogEntry(
        '$valveName opened for $duration ms', ComponentStatus.normal);

    await Future.delayed(Duration(seconds: duration));

    _componentValues.updateComponentCurrentValues(valveName, {'status': 0.0});
    addLogEntry(
        '$valveName closed after $duration ms', ComponentStatus.normal);
  }

  // Execute a purge step
  Future<void> _executePurgeStep(RecipeStep step) async {
    int duration = step.parameters['duration'] as int;

    _componentValues.updateComponentCurrentValues('Valve 1', {'status': 0.0});
    _componentValues.updateComponentCurrentValues('Valve 2', {'status': 0.0});
    _componentValues.updateComponentCurrentValues(
        'MFC', {'flow_rate': 100.0}); // Assume max flow rate for purge
    addLogEntry('Purge started for $duration ms', ComponentStatus.normal);

    await Future.delayed(Duration(seconds: duration));

    _componentValues.updateComponentCurrentValues('MFC', {'flow_rate': 0.0});
    addLogEntry(
        'Purge completed after $duration ms', ComponentStatus.normal);
  }

  // Execute a loop step
  Future<void> _executeLoopStep(RecipeStep step, double? parentTemperature,
      double? parentPressure) async {
    int iterations = step.parameters['iterations'] as int;

    // Fix the type casting by safely converting to double
    double? loopTemperature = step.parameters['temperature'] != null
        ? (step.parameters['temperature'] as num).toDouble()
        : null;

    double? loopPressure = step.parameters['pressure'] != null
        ? (step.parameters['pressure'] as num).toDouble()
        : null;

    double effectiveTemperature = loopTemperature ??
        _componentManager
            .getComponent('Reaction Chamber')!
            .currentValues['temperature']!;

    double effectivePressure = loopPressure ??
        _componentManager
            .getComponent('Reaction Chamber')!
            .currentValues['pressure']!;

    for (int i = 0; i < iterations; i++) {
      if (!_isSystemRunning) break;
      addLogEntry('Starting loop iteration ${i + 1} of $iterations',
          ComponentStatus.normal);

      await _setReactionChamberParameters(
          effectiveTemperature, effectivePressure);

      await _executeSteps(step.subSteps ?? [],
          inheritedTemperature: effectiveTemperature,
          inheritedPressure: effectivePressure);
    }
  }

  // Execute a set parameter step
  Future<void> _executeSetParameterStep(RecipeStep step) async {
    String componentName = step.parameters['component'] as String;
    String parameterName = step.parameters['parameter'] as String;
    double value = step.parameters['value'] as double;

    if (_componentManager.getComponent(componentName) != null) {
      _componentManager
          .updateComponentSetValues(componentName, {parameterName: value});
      addLogEntry('Set $parameterName of $componentName to $value',
          ComponentStatus.normal);
      await Future.delayed(const Duration(milliseconds: 500));
    } else {
      addAlarm('Unknown component: $componentName', AlarmSeverity.warning);
    }
  }

  // Set reaction chamber parameters
  Future<void> _setReactionChamberParameters(
      double temperature, double pressure) async {
    _componentManager.updateComponentSetValues('Reaction Chamber', {
      'temperature': temperature,
      'pressure': pressure,
    });
    addLogEntry(
        'Setting chamber temperature to $temperature°C and pressure to $pressure atm',
        ComponentStatus.normal);

    await Future.delayed(const Duration(seconds: 5));

    _componentManager.updateComponentCurrentValues('Reaction Chamber', {
      'temperature': temperature,
      'pressure': pressure,
    });
    addLogEntry('Chamber reached target temperature and pressure',
        ComponentStatus.normal);
  }

  // Add an alarm
  void addAlarm(String message, AlarmSeverity severity) {
    String? userId = _authService.currentUserId;
    if (userId == null) return;

    final newAlarm = Alarm(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      message: message,
      severity: severity,
      timestamp: DateTime.now(),
    );

    _alarmBloc.add(AddAlarmEvent(newAlarm, userId));
    addLogEntry('New alarm: ${newAlarm.message}', ComponentStatus.warning);
    notifyListeners();
  }

  // Acknowledge an alarm
  void acknowledgeAlarm(String alarmId) {
    String? userId = _authService.currentUserId;
    if (userId == null) return;

    _alarmBloc.add(AcknowledgeAlarmEvent(alarmId, userId));
    addLogEntry('Alarm acknowledged: $alarmId', ComponentStatus.normal);
    notifyListeners();
  }

  // Clear an alarm
  void clearAlarm(String alarmId) {
    String? userId = _authService.currentUserId;
    if (userId == null) return;

    _alarmBloc.add(ClearAlarmEvent(alarmId, userId));
    addLogEntry('Alarm cleared: $alarmId', ComponentStatus.normal);
    notifyListeners();
  }

  // Clear all acknowledged alarms
  void clearAllAcknowledgedAlarms() {
    String? userId = _authService.currentUserId;
    if (userId == null) return;

    _alarmBloc.add(ClearAllAcknowledgedAlarmsEvent(userId));
    addLogEntry('All acknowledged alarms cleared', ComponentStatus.normal);
    notifyListeners();
  }

  // Dispose resources
  @override
  void dispose() {
    _stopContinuousStateLogging();
    _simulationService.stopSimulation();
    super.dispose();
  }

  Future<void> updateComponentCurrentValues(String componentName, Map<String, double> newStates) {
    return _componentValues.updateComponentCurrentValues(componentName, newStates);
  }
}

