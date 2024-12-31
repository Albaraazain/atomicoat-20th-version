I'll start with the foundational overview section of the README, focusing on explaining the core concept of our ALD (Atomic Layer Deposition) Control System.

# ALD Control System
## System Overview and Core Concepts

The ALD Control System is a specialized Flutter application designed to control and monitor Atomic Layer Deposition processes. At its heart, this system manages the precise deposition of atomic layers of materials, a process that requires meticulous control over various parameters and precise timing of different steps.

### Understanding ALD Process Control

Atomic Layer Deposition is a cyclic process where thin films are built one atomic layer at a time. Each cycle typically consists of multiple steps, including precursor exposure, purging, and various parameter adjustments. Our system manages these cycles through what we call "recipes" - precise sequences of steps that define how a deposition process should occur.

Think of the system as a highly sophisticated cooking timer, but instead of just tracking time, it orchestrates multiple components (like valves and temperature controllers) while continuously monitoring various parameters (like pressure and temperature) to ensure the process proceeds exactly as specified.

### Single-Machine Operation Model

We've designed the system around a single-machine operation principle. This means:

Each machine operates independently, with its own dedicated control interface. Much like how a commercial kitchen might have multiple ovens but each requires individual attention, our ALD machines require focused operation. This design choice ensures maximum attention to safety and process precision.

The system enforces a one-operator-per-machine rule through a reservation system. When an operator begins a session, they gain exclusive control of the machine. This prevents conflicting commands and ensures clear accountability for each process run.

### Process Execution and Monitoring

During a typical operation:

The system continuously monitors multiple parameters, much like how a pilot monitors various instruments during a flight. These parameters might include:
- Chamber temperature
- System pressure
- Gas flow rates
- Valve states
- Sensor readings

All of this data is collected in real-time and stored as part of what we call an "experiment." Think of an experiment as a detailed lab notebook entry that automatically records everything that happened during the process, even if the operator doesn't add any additional notes.

### Data Collection and Experiment Recording

Every process execution automatically generates an experiment record. This is similar to how a black box records flight data - everything is captured whether or not someone actively chooses to record it. The system:

1. Records all parameter values throughout the process
2. Tracks any deviations from the recipe specifications
3. Notes any alerts or warnings that occurred
4. Captures the timing of each step
5. Stores all this information in a structured format for later analysis

When a process completes, operators have the opportunity to enrich this automated record with additional information, such as:
- Visual observations of the result
- Photos of the deposited film
- Notes about the substrate used
- Any unusual observations or conditions

Even if an operator chooses not to add this additional information, the system ensures that the core process data is never lost.

### Safety and Parameter Monitoring

Safety is a fundamental aspect of the system's design. Like a modern car's various safety systems that work together to prevent accidents, our system implements multiple layers of safety monitoring:

1. Continuous Parameter Validation: The system constantly checks that all parameters remain within safe ranges
2. Automatic Safety Interventions: If parameters deviate beyond acceptable limits, the system can automatically take corrective action
3. Process Validation: Before any recipe begins, the system verifies that all required components are functional and that the recipe's requirements are within the machine's capabilities

Let me start with detailing the first major component of our system: Authentication and Session Management.

## Authentication and Session Management

The authentication and session management system serves as the gateway to our ALD control system, ensuring secure access while maintaining the critical one-operator-per-machine principle. Think of it as an advanced key card system that not only controls who can enter but also tracks and manages their active sessions.

### Core Components

#### AuthService
This service handles all authentication-related operations, working directly with your authentication provider (like Firebase Auth). It manages:

```dart
class AuthService {
  // Core authentication operations
  Future<UserCredential> signIn(String email, String password);
  Future<void> signOut();

  // Session state monitoring
  Stream<User?> get authStateChanges;

  // Role and permission management
  Future<UserRole> getUserRole(String userId);
  Future<List<String>> getUserPermissions(String userId);
}
```

#### OperatorSession
This represents an active operator's interaction with a machine. It's crucial for maintaining the single-operator principle:

```dart
class OperatorSession {
  final String operatorId;
  final String machineId;
  final DateTime startTime;
  final SessionStatus status;

  // Tracks what the operator is currently doing
  ProcessStatus? currentProcessStatus;

  // Safety and validation methods
  bool canStartNewProcess();
  bool canModifyParameters();

  // Session management
  Future<void> endSession();
  Future<void> extendSession(Duration duration);
}
```

#### AuthProvider
This provider manages the application-wide authentication state and session information:

```dart
class AuthProvider extends ChangeNotifier {
  User? _currentUser;
  OperatorSession? _currentSession;

  // Active session tracking
  bool get hasActiveSession => _currentSession != null;

  // Permission checking
  bool canOperateMachine(String machineId);
  bool canCreateRecipes();

  // Session management
  Future<void> startMachineSession(String machineId);
  Future<void> endCurrentSession();
}
```

### Session Workflow

1. Initial Authentication:
```dart
// Operator logs in
await authService.signIn(email, password);

// System loads operator permissions
final permissions = await authService.getUserPermissions(userId);

// Provider updates application state
authProvider.updateCurrentUser(user, permissions);
```

2. Starting a Machine Session:
```dart
// Check machine availability
if (await machineProvider.isMachineAvailable(machineId)) {
  // Create new operator session
  final session = await authProvider.startMachineSession(machineId);

  // Initialize machine monitoring
  await machineProvider.initializeForOperator(session);

  // Begin parameter monitoring
  await parameterMonitor.startMonitoring(machineId);
}
```

3. Session Validation:
```dart
// Continuous session validation
Timer.periodic(Duration(minutes: 1), (_) {
  if (session.hasExpired()) {
    // Warn operator
    notificationService.showSessionExpiringWarning();

    // Begin shutdown sequence if no response
    if (session.gracePeriodExpired()) {
      processProvider.initiateShutdown();
    }
  }
});
```

### Safety and Security Considerations

1. Session Integrity:
- Each operator can only have one active session
- Sessions have a maximum duration
- Idle sessions are automatically terminated

2. Permission Enforcement:
- All operations are validated against operator permissions
- Machine-specific restrictions are enforced
- Critical operations require additional confirmation

3. Session Recovery:
```dart
// Handling unexpected disconnections
Future<void> handleDisconnection() async {
  // Save current process state
  await processProvider.saveProcessState();

  // Mark session for recovery
  await sessionManager.markForRecovery(sessionId);

  // Initiate safe machine state
  await machineProvider.enterSafeState();
}
```

### Integration with Other Components

The authentication system interacts with several other system components:

1. Machine Control:
```dart
// Session required for machine operations
if (!authProvider.hasActiveSession) {
  throw NotAuthorizedException('Active session required');
}

// Permission check for operation
if (!authProvider.canModifyParameters()) {
  throw NotAuthorizedException('Insufficient permissions');
}
```

2. Process Execution:
```dart
// Verify session before process start
Future<void> startProcess(Recipe recipe) async {
  final session = authProvider.currentSession;
  if (!session?.canStartNewProcess()) {
    throw SessionException('Cannot start new process');
  }

  // Update session status
  await session?.updateStatus(SessionStatus.processing);
}
```

3. Data Recording:
```dart
// Automatic session logging
class SessionLogger {
  Future<void> logSessionEvent(SessionEvent event) async {
    final logEntry = SessionLogEntry(
      operatorId: session.operatorId,
      machineId: session.machineId,
      eventType: event.type,
      timestamp: DateTime.now(),
      details: event.details
    );

    await logRepository.saveSessionLog(logEntry);
  }
}
```
Let me detail the Machine Management component of our ALD system. This is a crucial component that handles the core functionality and state of individual ALD machines.

## Machine Management

The Machine Management system serves as the digital representation of our physical ALD machine. Think of it as the machine's "nervous system" - it keeps track of every component, monitors all parameters, and ensures everything works together harmoniously. Just as your car's computer system monitors engine temperature, fuel levels, and tire pressure simultaneously, our machine management system keeps track of multiple components and their states in real-time.

### Core Components

#### Machine Model
The Machine model represents the physical ALD machine in our software:

```dart
class Machine {
  final String id;
  final String name;
  final MachineType type;
  final MachineSpecification specs;
  final MachineStatus status;
  final List<Component> components;
  final Map<String, ParameterRange> parameterLimits;

  // Capability checking methods
  bool canExecuteRecipe(Recipe recipe) {
    // Check if machine specifications match recipe requirements
    // Verify all needed components are available and functional
    // Ensure parameter ranges are compatible
    return _validateRecipeRequirements(recipe);
  }

  // State assessment methods
  bool isReadyForProcess() {
    // Check all components are in ready state
    // Verify parameters are within starting ranges
    // Ensure no active alerts
    return _validateMachineState();
  }

  // Safety validation
  ValidationResult validateParameters(Map<String, double> parameters) {
    // For each parameter, check against defined limits
    // Consider component interdependencies
    // Return detailed validation result
    return _performParameterValidation(parameters);
  }
}
```

#### Component Management
Each machine consists of multiple components, each with its own state and parameters:

```dart
class Component {
  final String id;
  final ComponentType type;
  final ComponentStatus status;
  final Map<String, Parameter> parameters;
  final List<SafetyRule> safetyRules;

  // Component control methods
  Future<void> activate() async {
    // Perform activation sequence
    // Monitor state changes
    // Verify successful activation
  }

  // State monitoring
  Stream<ComponentStatus> get statusStream {
    // Provide real-time status updates
    // Include parameter variations
    // Report safety violations
  }

  // Safety checks
  bool isSafeToOperate() {
    // Check all safety conditions
    // Verify dependencies
    // Validate current parameters
  }
}

class Parameter {
  final String id;
  final String name;
  final double currentValue;
  final ParameterRange allowedRange;
  final Unit unit;
  final List<Dependency> dependencies;

  // Parameter validation
  bool isInRange(double value) {
    // Check against allowed range
    // Consider environmental conditions
    // Validate against dependencies
  }

  // Change monitoring
  Stream<ParameterUpdate> get updateStream {
    // Provide real-time value updates
    // Include trend analysis
    // Flag rapid changes
  }
}
```

#### Machine Provider
The MachineProvider manages machine state and coordinates operations:

```dart
class MachineProvider extends ChangeNotifier {
  Machine? _currentMachine;
  Map<String, ComponentState> _componentStates = {};
  Map<String, double> _currentParameters = {};

  // Machine state management
  Future<void> initializeMachine(String machineId) async {
    // Load machine configuration
    // Initialize all components
    // Start monitoring systems
    await _setupMachineMonitoring();
  }

  // Parameter management
  Future<void> setParameter(String parameterId, double value) async {
    // Validate new value
    if (!await _validateParameterChange(parameterId, value)) {
      throw InvalidParameterException('Parameter value out of allowed range');
    }

    // Apply change
    await _applyParameterChange(parameterId, value);

    // Monitor effect
    _monitorParameterChange(parameterId);
  }

  // Component control
  Future<void> controlComponent(String componentId, ComponentCommand command) async {
    // Verify command safety
    if (!await _validateComponentCommand(componentId, command)) {
      throw UnsafeOperationException('Command violates safety rules');
    }

    // Execute command
    await _executeComponentCommand(componentId, command);

    // Monitor results
    _monitorComponentResponse(componentId);
  }
}
```

### Safety and Monitoring System

The machine management system implements multiple layers of safety:

```dart
class SafetyMonitor {
  // Continuous parameter monitoring
  void monitorParameters() {
    parameterStreams.listen((update) {
      // Check against safety limits
      if (!_isWithinSafetyLimits(update)) {
        _handleSafetyViolation(update);
      }

      // Monitor rate of change
      if (_isChangeRateExcessive(update)) {
        _handleExcessiveChange(update);
      }

      // Check interdependencies
      _validateParameterDependencies(update);
    });
  }

  // Component interaction safety
  Future<bool> validateComponentInteraction(
    Component source,
    Component target,
    InteractionType type
  ) async {
    // Check component compatibility
    if (!_areComponentsCompatible(source, target)) {
      return false;
    }

    // Verify safe interaction conditions
    if (!_areSafetyConditionsMet(source, target, type)) {
      return false;
    }

    return true;
  }

  // Emergency handling
  Future<void> handleEmergency(EmergencyType type) async {
    // Initiate emergency procedures
    await _startEmergencyProtocol(type);

    // Secure critical components
    await _secureCriticalComponents();

    // Log emergency event
    await _logEmergencyEvent(type);

    // Notify operators
    _notifyOperators(type);
  }
}
```

### Machine State Transitions

The system carefully manages state transitions to ensure safety:

```dart
class MachineStateManager {
  Future<void> transitionTo(MachineState targetState) async {
    // Validate transition
    if (!_isValidTransition(currentState, targetState)) {
      throw InvalidStateTransitionException(
        'Cannot transition from ${currentState} to ${targetState}'
      );
    }

    // Prepare for transition
    await _prepareForTransition(targetState);

    try {
      // Execute transition steps
      await _executeTransitionSequence(targetState);

      // Verify new state
      await _verifyStateTransition(targetState);

    } catch (e) {
      // Handle transition failure
      await _handleTransitionFailure(e);

      // Return to safe state
      await _returnToSafeState();
    }
  }
}
```

Let me detail the Process Execution system, which is the heart of our ALD control system. This component manages the actual execution of recipes, turning the theoretical recipe steps into real physical changes in the machine while ensuring safety and precision throughout the process.

## Process Execution System

The Process Execution system acts like an orchestra conductor, coordinating all the different components of the machine to perform the recipe steps in perfect harmony. Just as a conductor ensures each musician plays their part at exactly the right moment, our system ensures each component performs its operation with precise timing while maintaining all parameters within their specified ranges.

### Core Components

#### ProcessExecutor
The ProcessExecutor is responsible for managing the overall process execution:

```dart
class ProcessExecutor {
  final Recipe recipe;
  final Machine machine;
  final ProcessState state;
  final SafetyMonitor safetyMonitor;

  // Process execution control
  Future<void> startProcess() async {
    // First, we validate the entire recipe against machine capabilities
    await _validateRecipeRequirements();

    // Initialize all required components
    await _prepareComponents();

    try {
      // Execute recipe steps sequentially
      for (final step in recipe.steps) {
        // Begin executing the step
        await _executeStep(step);

        // Monitor execution and handle any deviations
        await _monitorStepExecution(step);

        // Validate step completion
        await _validateStepCompletion(step);
      }

      // Complete process and create experiment record
      await _finalizeProcess();

    } catch (e) {
      // Handle any execution errors
      await _handleProcessError(e);

      // Ensure machine returns to safe state
      await _recoverToSafeState();
    }
  }

  // Step execution handling
  Future<void> _executeStep(RecipeStep step) async {
    // Create step context with all required parameters
    final stepContext = await _createStepContext(step);

    // Execute based on step type
    switch (step.type) {
      case StepType.valve:
        await _executeValveOperation(step, stepContext);
        break;
      case StepType.purge:
        await _executePurgeOperation(step, stepContext);
        break;
      case StepType.loop:
        await _executeLoopOperation(step, stepContext);
        break;
      case StepType.setParameter:
        await _executeParameterSet(step, stepContext);
        break;
    }
  }

  // Real-time monitoring
  Future<void> _monitorStepExecution(RecipeStep step) async {
    // Start parameter monitoring
    final parameterMonitor = _createParameterMonitor(step);

    // Monitor until step completion or timeout
    await parameterMonitor.monitorUntilStable(
      timeout: step.timeout,
      onDeviation: _handleParameterDeviation,
      onStabilized: _markStepComplete
    );
  }
}
```

#### ProcessState
Manages the current state of process execution:

```dart
class ProcessState {
  final String processId;
  final ProcessStatus status;
  final DateTime startTime;
  final int currentStepIndex;
  final Map<String, double> currentParameters;
  final List<ProcessAlert> activeAlerts;

  // State tracking methods
  bool canProceedToNextStep() {
    // Verify current step is complete
    if (!_isCurrentStepComplete()) return false;

    // Check if parameters are stable
    if (!_areParametersStable()) return false;

    // Verify no blocking alerts
    if (_hasBlockingAlerts()) return false;

    return true;
  }

  // Parameter tracking
  void updateParameter(String parameterId, double value) {
    // Update parameter value
    _currentParameters[parameterId] = value;

    // Check for violations
    _checkParameterViolations(parameterId, value);

    // Update dependent parameters
    _updateDependentParameters(parameterId);
  }

  // Alert handling
  void handleAlert(ProcessAlert alert) {
    // Add new alert
    _activeAlerts.add(alert);

    // Check if process should pause
    if (alert.severity.requiresPause) {
      _initiateProcessPause(alert);
    }

    // Notify monitoring systems
    _notifyAlertHandlers(alert);
  }
}
```

#### ProcessMonitor
Handles real-time monitoring during process execution:

```dart
class ProcessMonitor {
  final StreamController<ProcessData> _dataStream;
  final Map<String, ParameterMonitor> _parameterMonitors;
  final AlertManager _alertManager;

  // Data collection and monitoring
  void startMonitoring() {
    // Initialize parameter monitors
    _parameterMonitors.forEach((param, monitor) {
      monitor.startMonitoring();

      // Set up parameter update handling
      monitor.updates.listen((update) {
        _handleParameterUpdate(param, update);
      });
    });

    // Start data collection
    _startDataCollection();

    // Begin safety monitoring
    _startSafetyMonitoring();
  }

  // Parameter monitoring
  void _handleParameterUpdate(String parameter, ParameterUpdate update) {
    // Check for threshold violations
    _checkThresholds(parameter, update.value);

    // Monitor rate of change
    _checkRateOfChange(parameter, update);

    // Update dependent parameters
    _updateDependencies(parameter);

    // Log parameter change
    _logParameterChange(parameter, update);
  }

  // Alert handling
  void _handleAlert(ProcessAlert alert) {
    // Log alert
    _logAlert(alert);

    // Check if process should pause
    if (alert.severity.requiresPause) {
      _initiateProcessPause(alert);
    }

    // Notify relevant systems
    _notifyAlertHandlers(alert);

    // Update process state
    _updateProcessState(alert);
  }
}
```

### Safety and Error Handling

The process execution system implements comprehensive safety measures:

```dart
class ProcessSafetyManager {
  // Continuous safety monitoring
  void monitorProcessSafety() {
    // Monitor critical parameters
    _monitorCriticalParameters();

    // Check component states
    _monitorComponentStates();

    // Verify process conditions
    _monitorProcessConditions();
  }

  // Emergency handling
  Future<void> handleEmergency(EmergencyType type) async {
    // Stop process execution
    await _stopProcess();

    // Secure critical components
    await _secureCriticalComponents();

    // Move to safe state
    await _moveToSafeState();

    // Log emergency
    await _logEmergencyEvent(type);

    // Notify operators
    _notifyOperators(type);
  }

  // Recovery procedures
  Future<void> recoverFromError(ProcessError error) async {
    // Analyze error condition
    final recovery = await _analyzeErrorCondition(error);

    // Execute recovery steps
    await _executeRecoveryProcedure(recovery);

    // Verify recovery success
    await _verifyRecovery(recovery);

    // Update process state
    await _updateProcessState(recovery);
  }
}
```

Let me explain the Experiment Recording system, which serves as our ALD system's "memory" - capturing, organizing, and preserving all the valuable data from each process execution. This system is crucial for scientific documentation, process optimization, and quality control.

## Experiment Recording System

Think of this system as an automated lab notebook that not only records what was planned to happen but also what actually occurred during the process. Just as a scientist meticulously documents their experiments, our system captures every detail of the ALD process, from the initial conditions to the final results.

### Core Components

#### ExperimentRecorder
This class serves as the primary gateway for recording experimental data:

```dart
class ExperimentRecorder {
  final String experimentId;
  final Recipe recipe;
  final ProcessData processData;
  final DataCollector dataCollector;
  final ExperimentStorage storage;

  // Initialization and setup
  Future<void> initializeRecording() async {
    // Create new experiment record
    final experiment = await _createExperimentRecord();

    // Initialize data collectors for each parameter
    await _setupParameterCollectors();

    // Prepare storage systems
    await _prepareStorage();

    // Begin baseline readings
    await _recordBaselineData();
  }

  // Real-time data collection
  Future<void> recordProcessData(ProcessDataPoint dataPoint) async {
    try {
      // Validate data point
      _validateDataPoint(dataPoint);

      // Process the data
      final processedData = await _processDataPoint(dataPoint);

      // Store in memory buffer
      _addToBuffer(processedData);

      // Periodically flush to permanent storage
      if (_shouldFlushBuffer()) {
        await _flushBufferToStorage();
      }

    } catch (e) {
      // Handle recording errors without disrupting process
      await _handleRecordingError(e);
    }
  }

  // Experiment completion
  Future<void> finalizeExperiment({
    ExperimentMetadata? metadata,
    List<String>? imagePaths,
    String? operatorNotes
  }) async {
    // Ensure all data is saved
    await _flushAllData();

    // Record completion metadata
    final completionData = ExperimentCompletionData(
      endTime: DateTime.now(),
      metadata: metadata,
      imagePaths: imagePaths,
      operatorNotes: operatorNotes
    );

    // Update experiment record
    await _updateExperimentRecord(completionData);

    // Generate experiment summary
    final summary = await _generateExperimentSummary();

    // Notify interested parties
    _notifyExperimentComplete(summary);
  }
}
```

#### ExperimentData
This class represents the comprehensive record of an experiment:

```dart
class ExperimentData {
  final String id;
  final DateTime startTime;
  final DateTime? endTime;
  final Recipe recipe;
  final String machineId;
  final String operatorId;

  // Process data
  final List<ProcessDataPoint> timeSeriesData;
  final Map<String, List<ParameterReading>> parameterReadings;
  final List<ProcessEvent> events;

  // Results and metadata
  final ExperimentMetadata? metadata;
  final List<String>? resultImages;
  final String? operatorNotes;

  // Analysis methods
  Map<String, ParameterStatistics> calculateParameterStatistics() {
    return _computeParameterStats(parameterReadings);
  }

  List<ProcessDeviation> findProcessDeviations() {
    return _analyzeProcessDeviations(timeSeriesData, recipe);
  }

  ExperimentSummary generateSummary() {
    return ExperimentSummary(
      id: id,
      startTime: startTime,
      endTime: endTime,
      recipeId: recipe.id,
      deviations: findProcessDeviations(),
      stats: calculateParameterStatistics()
    );
  }
}
```

#### DataCollector
Handles the real-time collection and buffering of process data:

```dart
class DataCollector {
  final CircularBuffer<ProcessDataPoint> _buffer;
  final Map<String, ParameterCollector> _collectors;
  final StreamController<ProcessDataPoint> _dataStream;

  // Data collection configuration
  void configureCollection(CollectionConfig config) {
    // Set up sampling rates for each parameter
    _configureSamplingRates(config.samplingRates);

    // Initialize data buffers
    _initializeBuffers(config.bufferSizes);

    // Set up data preprocessing
    _configurePreprocessing(config.preprocessing);
  }

  // Real-time data collection
  void collectParameterData(String parameterId, double value) {
    // Create data point with timestamp
    final dataPoint = ProcessDataPoint(
      parameterId: parameterId,
      value: value,
      timestamp: DateTime.now()
    );

    // Preprocess data
    final processedPoint = _preprocessData(dataPoint);

    // Add to buffer
    _addToBuffer(processedPoint);

    // Emit to stream
    _dataStream.add(processedPoint);
  }

  // Data buffering and storage
  Future<void> flushBuffer() async {
    // Get all buffered data
    final bufferedData = _buffer.drain();

    // Process batch
    final processedBatch = await _processBatch(bufferedData);

    // Save to storage
    await _saveToStorage(processedBatch);
  }
}
```

### Experiment Completion Handling

The system provides a comprehensive experiment completion workflow:

```dart
class ExperimentCompletionHandler {
  // Handle experiment completion
  Future<void> handleCompletion(String experimentId) async {
    // Load experiment data
    final experiment = await _loadExperiment(experimentId);

    // Generate automatic analysis
    final analysis = await _analyzeExperiment(experiment);

    // Show completion dialog to operator
    final userInput = await _showCompletionDialog(analysis);

    if (userInput != null) {
      // Update with operator input
      await _updateExperiment(experimentId, userInput);
    }

    // Generate final report
    final report = await _generateReport(experimentId);

    // Archive experiment data
    await _archiveExperiment(experimentId);

    // Notify relevant parties
    await _notifyCompletion(report);
  }

  // Automatic analysis generation
  Future<ExperimentAnalysis> _analyzeExperiment(ExperimentData data) async {
    return ExperimentAnalysis(
      parameterStats: data.calculateParameterStatistics(),
      processDeviations: data.findProcessDeviations(),
      qualityMetrics: await _calculateQualityMetrics(data),
      recommendations: await _generateRecommendations(data)
    );
  }
}
```

### Data Storage and Retrieval

The system implements robust data storage and retrieval capabilities:

```dart
class ExperimentStorage {
  // Data storage operations
  Future<void> saveExperiment(ExperimentData experiment) async {
    // Compress time series data
    final compressedData = await _compressTimeSeriesData(
      experiment.timeSeriesData
    );

    // Store main experiment record
    await _storeExperimentRecord(experiment);

    // Store compressed time series data
    await _storeTimeSeriesData(experiment.id, compressedData);

    // Store metadata and images
    await _storeMetadata(experiment.id, experiment.metadata);

    // Update indexes
    await _updateExperimentIndexes(experiment);
  }

  // Data retrieval operations
  Future<ExperimentData> loadExperiment(String experimentId) async {
    // Load experiment record
    final record = await _loadExperimentRecord(experimentId);

    // Load time series data
    final timeSeriesData = await _loadTimeSeriesData(experimentId);

    // Load metadata and images
    final metadata = await _loadMetadata(experimentId);

    // Reconstruct experiment data
    return ExperimentData.reconstruct(
      record: record,
      timeSeriesData: timeSeriesData,
      metadata: metadata
    );
  }
}
```

## Core Concepts

### Recipes, Processes, and Experiments

The ALD control system distinguishes between three key concepts:

1. **Recipe**
   - A recipe is a reusable template that defines the sequence of steps needed to perform an ALD process
   - It contains:
     - Sequence of steps (precursor pulses, purge steps, etc.)
     - Parameter set points (temperature, pressure, etc.)
     - Substrate specifications
     - Machine-specific configurations
   - Think of it as a "cooking recipe" that can be executed multiple times

2. **Process**
   - A process is the actual execution of a recipe on the ALD machine
   - It represents the real-time operation where:
     - Steps are being executed
     - Parameters are being monitored
     - Controls are being adjusted
     - Valves are being operated
   - It's the "cooking" phase where the recipe is being followed

3. **Experiment**
   - An experiment is a complete record of a process execution
   - It includes:
     - The recipe that was used
     - All process data collected during execution
     - Results and measurements
     - Quality metrics and analysis
     - Operator notes and observations
   - Think of it as the "lab notebook entry" that documents everything about a process run

### Relationships
- A single recipe can be used in many processes
- Each process execution creates one experiment record
- Experiments can be compared to analyze consistency and optimize recipes

This separation allows:
- Recipe standardization and version control
- Real-time process monitoring and control
- Comprehensive experiment analysis and quality improvement
