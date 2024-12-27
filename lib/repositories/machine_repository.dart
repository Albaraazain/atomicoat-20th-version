// lib/repositories/machine_repository.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import '../modules/system_operation_also_main_module/models/machine.dart';
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
        .get();

    // Get the parent machine documents for user machines
    final userMachineIds = userMachinesSnapshot.docs.map((doc) => doc.reference.parent.parent!.id).toList();
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
      if (experimentId != null) 'currentExperiment': experimentId,
    };
    await getCollection().doc(machineId).update(updates);
  }

  // Add user to machine
  Future<void> addUserToMachine(String machineId, String userId, String role) async {
    await _firestore
        .collection('machines')
        .doc(machineId)
        .collection('users')
        .doc(userId)
        .set({
          'userId': userId,
          'role': role,
          'addedAt': FieldValue.serverTimestamp(),
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

  // Get all users for a machine
  Future<List<Map<String, dynamic>>> getMachineUsers(String machineId) async {
    final snapshot = await _firestore
        .collection('machines')
        .doc(machineId)
        .collection('users')
        .get();

    return snapshot.docs.map((doc) => doc.data()).toList();
  }

  // Get machines by location
  Future<List<Machine>> getMachinesByLocation(String location) async {
    final QuerySnapshot snapshot = await getCollection()
        .where('location', isEqualTo: location)
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

    // Check if user is in users subcollection
    final userDoc = await _firestore
        .collection('machines')
        .doc(machineId)
        .collection('users')
        .doc(userId)
        .get();

    return userDoc.exists;
  }
}