import 'package:flutter/foundation.dart';
import '../../../repositories/machine_repository.dart';
import '../../../services/auth_service.dart';
import '../models/machine.dart';

class MachineProvider with ChangeNotifier {
  final MachineRepository _machineRepository;
  final AuthService _authService;
  List<Machine> _machines = [];
  bool _isLoading = false;
  String? _error;

  MachineProvider(this._machineRepository, this._authService);

  List<Machine> get machines => _machines;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadMachines() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final userId = _authService.currentUser?.uid;
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      _machines = await _machineRepository.getMachinesForUser(userId);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  Future<void> createMachine(Machine machine) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      await _machineRepository.add(machine.id, machine);
      await loadMachines();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  Future<void> updateMachine(Machine machine) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      await _machineRepository.update(machine.id, machine);
      await loadMachines();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
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

      await _machineRepository.addUserToMachine(machineId, userId, role);
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
}