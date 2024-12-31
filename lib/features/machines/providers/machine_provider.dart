import 'package:flutter/foundation.dart';
import '../../../repositories/machine_repository.dart';
import '../../../services/auth_service.dart';
import '../../../services/console_logger.dart';
import '../models/machine.dart';

class MachineProvider with ChangeNotifier {
  final MachineRepository _machineRepository;
  final AuthService _authService;
  final ConsoleLogger _logger = ConsoleLogger();
  List<Machine> _machines = [];
  bool _isLoading = false;
  String? _error;

  MachineProvider(this._machineRepository, this._authService) {
    _logger.debug('Initializing MachineProvider');
  }

  List<Machine> get machines => _machines;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadMachines() async {
    _logger.info('Loading machines');

    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final userId = _authService.currentUser?.uid;
      if (userId == null) {
        const error = 'User not authenticated';
        _logger.error(error);
        throw Exception(error);
      }

      _machines = await _machineRepository.getMachinesForUser(userId);

      _logger.info(
        'Machines loaded successfully',
        data: {
          'userId': userId,
          'machineCount': _machines.length,
          'machineIds': _machines.map((m) => m.id).toList(),
        },
      );

      _isLoading = false;
      notifyListeners();
    } catch (e, stackTrace) {
      _error = e.toString();
      _isLoading = false;

      _logger.error(
        'Failed to load machines',
        error: e,
        stackTrace: stackTrace,
        data: {'userId': _authService.currentUser?.uid},
      );

      notifyListeners();
      rethrow;
    }
  }

  Future<void> createMachine(Machine machine) async {
    _logger.info(
      'Creating machine',
      data: {
        'machineId': machine.id,
        'serialNumber': machine.serialNumber,
        'adminId': machine.adminId,
      },
    );

    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      await _machineRepository.add(machine.id, machine);

      _logger.info(
        'Machine created successfully',
        data: {
          'machineId': machine.id,
          'serialNumber': machine.serialNumber,
          'adminId': machine.adminId,
        },
      );

      await loadMachines();
    } catch (e, stackTrace) {
      _error = e.toString();
      _isLoading = false;

      _logger.error(
        'Failed to create machine',
        error: e,
        stackTrace: stackTrace,
        data: {
          'machineId': machine.id,
          'serialNumber': machine.serialNumber,
          'adminId': machine.adminId,
        },
      );

      notifyListeners();
      rethrow;
    }
  }

  Future<void> updateMachine(Machine machine) async {
    _logger.info(
      'Updating machine',
      data: {
        'machineId': machine.id,
        'serialNumber': machine.serialNumber,
        'adminId': machine.adminId,
      },
    );

    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      await _machineRepository.update(machine.id, machine);

      _logger.info(
        'Machine updated successfully',
        data: {
          'machineId': machine.id,
          'serialNumber': machine.serialNumber,
          'adminId': machine.adminId,
        },
      );

      await loadMachines();
    } catch (e, stackTrace) {
      _error = e.toString();
      _isLoading = false;

      _logger.error(
        'Failed to update machine',
        error: e,
        stackTrace: stackTrace,
        data: {
          'machineId': machine.id,
          'serialNumber': machine.serialNumber,
          'adminId': machine.adminId,
        },
      );

      notifyListeners();
      rethrow;
    }
  }

  Future<void> deleteMachine(String machineId) async {
    _logger.info(
      'Deleting machine',
      data: {'machineId': machineId},
    );

    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      await _machineRepository.delete(machineId);

      _logger.info(
        'Machine deleted successfully',
        data: {'machineId': machineId},
      );

      await loadMachines();
    } catch (e, stackTrace) {
      _error = e.toString();
      _isLoading = false;

      _logger.error(
        'Failed to delete machine',
        error: e,
        stackTrace: stackTrace,
        data: {'machineId': machineId},
      );

      notifyListeners();
      rethrow;
    }
  }

  Future<void> updateMachineStatus(String machineId, MachineStatus status) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      await _machineRepository.updateMachineStatus(machineId, status);
      await loadMachines();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  Future<void> addUserToMachine(String machineId, String userId, String role) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      await _machineRepository.addApprovedUserToMachine(machineId, userId, role);
      await loadMachines();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  Future<void> removeUserFromMachine(String machineId, String userId) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      await _machineRepository.removeUserFromMachine(machineId, userId);
      await loadMachines();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> getMachineUsers(String machineId) async {
    try {
      return await _machineRepository.getMachineUsers(machineId);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  Future<void> logMaintenance(Machine machine) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final updatedMachine = machine.copyWith(
        lastMaintenance: DateTime.now(),
        status: MachineStatus.maintenance,
      );

      await _machineRepository.update(machine.id, updatedMachine);
      await loadMachines();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  @override
  void dispose() {
    _logger.debug('Disposing MachineProvider');
    super.dispose();
  }
}