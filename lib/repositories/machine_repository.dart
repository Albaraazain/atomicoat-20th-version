// lib/repositories/machine_repository.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import '../modules/system_operation_also_main_module/models/machine.dart';
import '../modules/system_operation_also_main_module/models/system_component.dart';
import 'base_repository.dart';

class MachineRepository extends BaseRepository<Machine> {
  final FirebaseFirestore _firestore;

  MachineRepository({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance,
      super('machines', firestore: firestore);

  @override
  Machine fromJson(Map<String, dynamic> json) => Machine.fromJson(json);

  // Get machines where user has access (either as admin or researcher)
  Future<List<Machine>> getMachinesForUser(String userId) async {
    // First get machines where user is admin
    final adminSnapshot = await getCollection()
        .where('adminId', isEqualTo: userId)
        .get();

    // Then get machines where user is in users subcollection
    final userMachinesSnapshot = await _firestore.collectionGroup('users')
        .where('userId', isEqualTo: userId)
        .where('status', isEqualTo: 'active')  // Only get active users
        .get();

    // Get the parent machine documents for user machines
    final userMachineIds = userMachinesSnapshot.docs.map((doc) => doc.reference.parent.parent!.id).toList();

    if (userMachineIds.isEmpty) {
      return adminSnapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return Machine.fromJson(data);
      }).toList();
    }

    final userMachinesQuery = await getCollection()
        .where(FieldPath.documentId, whereIn: userMachineIds)
        .get();

    // Combine and deduplicate results
    final allDocs = [...adminSnapshot.docs, ...userMachinesQuery.docs];
    final uniqueDocs = allDocs.toSet().toList();

    return uniqueDocs.map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      data['id'] = doc.id;
      return Machine.fromJson(data);
    }).toList();
  }

  // Add or update a component for a machine
  Future<void> updateMachineComponent(String machineId, SystemComponent component) async {
    final machineDoc = getCollection().doc(machineId);
    final machineSnapshot = await machineDoc.get();

    if (!machineSnapshot.exists) {
      throw Exception('Machine not found');
    }

    final machine = Machine.fromJson(machineSnapshot.data() as Map<String, dynamic>);
    final updatedComponents = Map<String, SystemComponent>.from(machine.components);
    updatedComponents[component.id] = component;

    await machineDoc.update({
      'components': updatedComponents.map((key, value) => MapEntry(key, value.toJson())),
    });
  }

  // Remove a component from a machine
  Future<void> removeMachineComponent(String machineId, String componentId) async {
    final machineDoc = getCollection().doc(machineId);
    final machineSnapshot = await machineDoc.get();

    if (!machineSnapshot.exists) {
      throw Exception('Machine not found');
    }

    final machine = Machine.fromJson(machineSnapshot.data() as Map<String, dynamic>);
    final updatedComponents = Map<String, SystemComponent>.from(machine.components);
    updatedComponents.remove(componentId);

    await machineDoc.update({
      'components': updatedComponents.map((key, value) => MapEntry(key, value.toJson())),
    });
  }

  // Get all components for a machine
  Future<Map<String, SystemComponent>> getMachineComponents(String machineId) async {
    final machineDoc = await getCollection().doc(machineId).get();

    if (!machineDoc.exists) {
      throw Exception('Machine not found');
    }

    final machine = Machine.fromJson(machineDoc.data() as Map<String, dynamic>);
    return machine.components;
  }

  // Update machine status
  Future<void> updateMachineStatus(String machineId, MachineStatus status) async {
    await getCollection().doc(machineId).update({
      'status': status.toString().split('.').last,
    });
  }

  // Set current operator and experiment
  Future<void> setCurrentOperator(String machineId, String? operatorId, {String? experimentId}) async {
    final updates = {
      'currentOperator': operatorId,
      'status': operatorId != null ? MachineStatus.running.toString().split('.').last : MachineStatus.idle.toString().split('.').last,
      if (experimentId != null) 'currentExperiment': experimentId,
    };
    await getCollection().doc(machineId).update(updates);
  }

  // Add user to machine with role and status
  Future<void> addUserToMachine(String machineId, String userId, String role) async {
    await _firestore
        .collection('machines')
        .doc(machineId)
        .collection('users')
        .doc(userId)
        .set({
          'userId': userId,
          'role': role,
          'status': 'active',
          'addedAt': FieldValue.serverTimestamp(),
          'lastAccess': FieldValue.serverTimestamp(),
        });
  }

  // Remove user from machine
  Future<void> removeUserFromMachine(String machineId, String userId) async {
    await _firestore
        .collection('machines')
        .doc(machineId)
        .collection('users')
        .doc(userId)
        .delete();
  }

  // Get users for a machine
  Future<List<Map<String, dynamic>>> getMachineUsers(String machineId) async {
    final usersSnapshot = await _firestore
        .collection('machines')
        .doc(machineId)
        .collection('users')
        .where('status', isEqualTo: 'active')
        .get();

    return usersSnapshot.docs.map((doc) => doc.data()).toList();
  }

  // Get machines by lab
  Future<List<Machine>> getMachinesByLab(String labName, String institution) async {
    final QuerySnapshot snapshot = await getCollection()
        .where('labName', isEqualTo: labName)
        .where('labInstitution', isEqualTo: institution)
        .get();

    return snapshot.docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      data['id'] = doc.id;
      return Machine.fromJson(data);
    }).toList();
  }

  // Check if user has access to machine
  Future<bool> userHasAccessToMachine(String machineId, String userId) async {
    // Check if user is admin
    final machine = await getCollection().doc(machineId).get();
    if (machine.exists) {
      final data = machine.data() as Map<String, dynamic>;
      if (data['adminId'] == userId) {
        return true;
      }
    }

    // Check if user is in users subcollection and active
    final userDoc = await _firestore
        .collection('machines')
        .doc(machineId)
        .collection('users')
        .doc(userId)
        .get();

    return userDoc.exists && userDoc.data()?['status'] == 'active';
  }

  // Update user's last access time
  Future<void> updateUserLastAccess(String machineId, String userId) async {
    await _firestore
        .collection('machines')
        .doc(machineId)
        .collection('users')
        .doc(userId)
        .update({
          'lastAccess': FieldValue.serverTimestamp(),
        });
  }
}