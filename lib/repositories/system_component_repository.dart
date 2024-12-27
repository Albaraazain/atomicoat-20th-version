// lib/repositories/system_component_repository.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import '../modules/system_operation_also_main_module/models/system_component.dart';
import 'base_repository.dart';
import 'machine_repository.dart';

class SystemComponentRepository extends BaseRepository<SystemComponent> {
  final MachineRepository _machineRepository;

  SystemComponentRepository({FirebaseFirestore? firestore})
      : _machineRepository = MachineRepository(firestore: firestore),
        super('components', firestore: firestore);

  @override
  SystemComponent fromJson(Map<String, dynamic> json) => SystemComponent.fromJson(json);

  Future<Map<String, SystemComponent>> getMachineComponents(String machineId) async {
    return _machineRepository.getMachineComponents(machineId);
  }

  Future<void> updateMachineComponent(String machineId, SystemComponent component) async {
    await _machineRepository.updateMachineComponent(machineId, component);
  }

  Future<void> removeMachineComponent(String machineId, String componentId) async {
    await _machineRepository.removeMachineComponent(machineId, componentId);
  }
}