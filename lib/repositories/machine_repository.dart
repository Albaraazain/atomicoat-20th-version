// lib/repositories/machine_repository.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import '../modules/system_operation_also_main_module/models/machine.dart';
import 'base_repository.dart';

class MachineRepository extends BaseRepository<Machine> {
  MachineRepository({FirebaseFirestore? firestore}) : super('machines', firestore: firestore);

  @override
  Machine fromJson(Map<String, dynamic> json) => Machine.fromJson(json);

  // Get machines where user has access
  Future<List<Machine>> getMachinesForUser(String userId) async {
    final QuerySnapshot snapshot = await getCollection()
        .where('adminUsers.$userId', isNull: false)
        .get();

    return snapshot.docs
        .map((doc) {
          final data = doc.data() as Map<String, dynamic>;
          data['id'] = doc.id;
          return Machine.fromJson(data);
        })
        .toList();
  }

  // Update machine status
  Future<void> updateMachineStatus(String machineId, MachineStatus status) async {
    await getCollection().doc(machineId).update({
      'status': status.toString().split('.').last,
    });
  }

  // Set current operator
  Future<void> setCurrentOperator(String machineId, String? operatorId) async {
    await getCollection().doc(machineId).update({
      'currentOperator': operatorId,
    });
  }

  // Add admin user to machine
  Future<void> addAdminUser(String machineId, String userId, String role) async {
    await getCollection().doc(machineId).update({
      'adminUsers.$userId': role,
    });
  }

  // Remove admin user from machine
  Future<void> removeAdminUser(String machineId, String userId) async {
    await getCollection().doc(machineId).update({
      'adminUsers.$userId': FieldValue.delete(),
    });
  }

  // Get machines by location
  Future<List<Machine>> getMachinesByLocation(String location) async {
    final QuerySnapshot snapshot = await getCollection()
        .where('location', isEqualTo: location)
        .get();

    return snapshot.docs
        .map((doc) {
          final data = doc.data() as Map<String, dynamic>;
          data['id'] = doc.id;
          return Machine.fromJson(data);
        })
        .toList();
  }
}