import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Verify if a bracelet ID exists in the Firestore
  Future<bool> verifyBracelet(String qrCode) async {
    final result = await _db.collection('bracelets').doc(qrCode).get();
    return result.exists; // Return true if bracelet exists, false otherwise
  }

  // Add a new user (either assistant or patient)
  Future<void> addUser({
    required String id,
    required String name,
    required String email,
    required String phone,
    required String password,
    required String type,
  }) async {
    await _db.collection('users').doc(id).set({
      'name': name,
      'email': email,
      'phone': phone,
      'password': password,
      'type': type,
    });
  }

  // Add assistant info to Firestore
  Future<void> addAssistant({required String userId, required String assignedPatientId}) async {
    await _db.collection('assistants').doc(userId).set({
      'assignedPatientId': assignedPatientId,
    });
  }

  // Add patient info to Firestore
  Future<void> addPatient({
    required String userId,
    required String patientName,
    required int age,
    required String medicalData,
  }) async {
    await _db.collection('patients').doc(userId).set({
      'patientName': patientName,
      'age': age,
      'medicalData': medicalData,
    });
  }

  // Register bracelet to a patient
  Future<void> registerBracelet({required String braceletId, required String patientId}) async {
    await _db.collection('bracelets').doc(braceletId).update({
      'patientId': patientId,
    });
  }
}
