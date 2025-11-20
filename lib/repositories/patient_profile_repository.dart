import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/patient_profile.dart';

class PatientProfileRepository {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  PatientProfileRepository({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  String get _uid {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User chưa đăng nhập');
    return user.uid;
  }

  CollectionReference<Map<String, dynamic>> _profilesRef() {
    return _firestore
        .collection('users')
        .doc(_uid)
        .collection('profiles');
  }

  Stream<List<PatientProfile>> streamProfiles() {
    return _profilesRef().snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => PatientProfile.fromFirestore(doc.data(), doc.id))
          .toList();
    });
  }

  Future<List<PatientProfile>> getProfilesOnce() async {
    final snap = await _profilesRef().get();
    return snap.docs
        .map((doc) => PatientProfile.fromFirestore(doc.data(), doc.id))
        .toList();
  }

  Future<PatientProfile?> getDefaultProfile() async {
    final snap = await _profilesRef()
        .where('isDefault', isEqualTo: true)
        .limit(1)
        .get();

    if (snap.docs.isEmpty) return null;

    final doc = snap.docs.first;
    return PatientProfile.fromFirestore(doc.data(), doc.id);
  }

  Future<String> createProfile(PatientProfile profile) async {
    final data = profile.toMap();
    final docRef = await _profilesRef().add(data);
    return docRef.id;
  }

  Future<void> updateProfile(PatientProfile profile) async {
    await _profilesRef().doc(profile.id).update(profile.toMap());
  }

  Future<void> deleteProfile(String profileId) async {
    await _profilesRef().doc(profileId).delete();
  }

  /// Đặt 1 hồ sơ là mặc định, các hồ sơ khác bỏ isDefault
  Future<void> setDefaultProfile(String profileId) async {
    final batch = _firestore.batch();
    final allDocs = await _profilesRef().get();

    for (final doc in allDocs.docs) {
      batch.update(doc.reference, {
        'isDefault': doc.id == profileId,
      });
    }

    await batch.commit();
  }
}
