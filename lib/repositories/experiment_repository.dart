// lib/repositories/experiment_repository.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import '../modules/system_operation_also_main_module/models/experiment.dart';
import 'base_repository.dart';

class ExperimentRepository extends BaseRepository<Experiment> {
  final FirebaseFirestore _firestore;

  ExperimentRepository({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance,
      super('experiments', firestore: firestore);

  @override
  Experiment fromJson(Map<String, dynamic> json) => Experiment.fromJson(json);

  // Create a new experiment
  Future<void> createExperiment(String machineId, Experiment experiment) async {
    final machineRef = _firestore.collection('machines').doc(machineId);
    final experimentRef = machineRef.collection('experiments').doc(experiment.id);

    await _firestore.runTransaction((transaction) async {
      // Update machine status and current experiment
      transaction.update(machineRef, {
        'status': 'running',
        'currentOperator': experiment.researcherId,
        'currentExperiment': experiment.id,
      });

      // Create the experiment document
      transaction.set(experimentRef, {
        ...experiment.toJson(),
        'createdAt': FieldValue.serverTimestamp(),
      });

      // Create monitoring configuration document
      transaction.set(
        experimentRef.collection('monitoring').doc('config'),
        experiment.monitoringConfig,
      );
    });
  }

  // Update experiment status and details
  Future<void> updateExperimentStatus(
    String machineId,
    String experimentId,
    ExperimentStatus status, {
    int? completedCycles,
    DateTime? endTime,
    Map<String, dynamic>? results,
    String? notes,
  }) async {
    final experimentRef = _firestore
        .collection('machines')
        .doc(machineId)
        .collection('experiments')
        .doc(experimentId);

    final updates = {
      'status': status.toString().split('.').last,
      'lastUpdated': FieldValue.serverTimestamp(),
      if (completedCycles != null) 'completedCycles': completedCycles,
      if (endTime != null) 'endTime': Timestamp.fromDate(endTime),
      if (results != null) 'results': results,
      if (notes != null) 'notes': notes,
    };

    if (status == ExperimentStatus.completed || status == ExperimentStatus.failed) {
      // Also update machine status when experiment ends
      final machineRef = _firestore.collection('machines').doc(machineId);
      await _firestore.runTransaction((transaction) async {
        transaction.update(experimentRef, updates);
        transaction.update(machineRef, {
          'status': 'idle',
          'currentOperator': null,
          'currentExperiment': null,
        });
      });
    } else {
      await experimentRef.update(updates);
    }
  }

  // Record monitoring data for an experiment
  Future<void> recordMonitoringData(
    String machineId,
    String experimentId,
    Map<String, dynamic> componentStates,
  ) async {
    final monitoringRef = _firestore
        .collection('machines')
        .doc(machineId)
        .collection('experiments')
        .doc(experimentId)
        .collection('monitoring_data');

    await monitoringRef.add({
      'timestamp': FieldValue.serverTimestamp(),
      'componentStates': componentStates,
      'cycle': componentStates['currentCycle'],
    });
  }

  // Get experiment by ID
  Future<Experiment?> getExperiment(String machineId, String experimentId) async {
    final doc = await _firestore
        .collection('machines')
        .doc(machineId)
        .collection('experiments')
        .doc(experimentId)
        .get();

    if (doc.exists) {
      final data = doc.data() as Map<String, dynamic>;
      data['id'] = doc.id;
      return Experiment.fromJson(data);
    }
    return null;
  }

  // Get all experiments for a machine
  Future<List<Experiment>> getMachineExperiments(String machineId) async {
    final snapshot = await _firestore
        .collection('machines')
        .doc(machineId)
        .collection('experiments')
        .orderBy('startTime', descending: true)
        .get();

    return snapshot.docs.map((doc) {
      final data = doc.data();
      data['id'] = doc.id;
      return Experiment.fromJson(data);
    }).toList();
  }

  // Get experiments by researcher
  Future<List<Experiment>> getResearcherExperiments(String researcherId) async {
    final experiments = await _firestore
        .collectionGroup('experiments')
        .where('researcherId', isEqualTo: researcherId)
        .orderBy('startTime', descending: true)
        .get();

    return experiments.docs.map((doc) {
      final data = doc.data();
      data['id'] = doc.id;
      return Experiment.fromJson(data);
    }).toList();
  }

  // Get monitoring data for a specific time range
  Future<List<Map<String, dynamic>>> getMonitoringData(
    String machineId,
    String experimentId, {
    DateTime? start,
    DateTime? end,
    int? cycle,
  }) async {
    var query = _firestore
        .collection('machines')
        .doc(machineId)
        .collection('experiments')
        .doc(experimentId)
        .collection('monitoring_data')
        .orderBy('timestamp');

    if (cycle != null) {
      query = query.where('cycle', isEqualTo: cycle);
    } else {
      if (start != null) {
        query = query.where('timestamp', isGreaterThanOrEqualTo: Timestamp.fromDate(start));
      }
      if (end != null) {
        query = query.where('timestamp', isLessThanOrEqualTo: Timestamp.fromDate(end));
      }
    }

    final snapshot = await query.get();
    return snapshot.docs.map((doc) => doc.data()).toList();
  }

  // Get monitoring configuration
  Future<Map<String, dynamic>> getMonitoringConfig(String machineId, String experimentId) async {
    final doc = await _firestore
        .collection('machines')
        .doc(machineId)
        .collection('experiments')
        .doc(experimentId)
        .collection('monitoring')
        .doc('config')
        .get();

    return doc.data() ?? {};
  }

  // Update monitoring configuration
  Future<void> updateMonitoringConfig(
    String machineId,
    String experimentId,
    Map<String, dynamic> config,
  ) async {
    await _firestore
        .collection('machines')
        .doc(machineId)
        .collection('experiments')
        .doc(experimentId)
        .collection('monitoring')
        .doc('config')
        .set(config, SetOptions(merge: true));
  }

  // Get experiments by date range
  Future<List<Experiment>> getExperimentsByDateRange(
    String machineId,
    DateTime start,
    DateTime end,
  ) async {
    final snapshot = await _firestore
        .collection('machines')
        .doc(machineId)
        .collection('experiments')
        .where('startTime', isGreaterThanOrEqualTo: Timestamp.fromDate(start))
        .where('startTime', isLessThanOrEqualTo: Timestamp.fromDate(end))
        .orderBy('startTime', descending: true)
        .get();

    return snapshot.docs.map((doc) {
      final data = doc.data();
      data['id'] = doc.id;
      return Experiment.fromJson(data);
    }).toList();
  }
}