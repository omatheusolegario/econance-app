import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FamilyService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<String?> getUserFamilyId(String uid) async{
    final snap = await _db.collection('users').doc(uid).get();
    final data = snap.data();
    return data != null && data['personalInfo'] != null ? data['personalInfo']['familyId'] as String? : null;
  }

  Future<String> createFamily({required String name}) async{
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final famRef = await _db.collection('families').add({
      'name': name,
      'createdByUid': uid,
      'createdAt': FieldValue.serverTimestamp(),
    });

    await famRef.collection('members').doc(uid).set({
      'role': 'admin',
      'joinedAt': FieldValue.serverTimestamp(),
      'displayName': FirebaseAuth.instance.currentUser!.displayName ?? '',
      'email': FirebaseAuth.instance.currentUser!.email ?? '',
    });

    await _db.collection('users').doc(uid).set({
      'personalInfo': FieldValue.serverTimestamp()
    }, SetOptions(merge: true));
    await _db.collection('users').doc(uid).set({
      'personalInfo': {'familyId': famRef.id}
    }, SetOptions(merge: true));

    return famRef.id;
  }

  Stream<DocumentSnapshot> familyDocStream(String familyId){
    return _db.collection('families').doc(familyId).snapshots();
  }

  Stream<QuerySnapshot> membersStream(String familyId){
    return _db.collection('families').doc(familyId).collection('members').snapshots();
  }

  Future<void> inviteByEmail(String familyId, String email)async{
    final uid = FirebaseAuth.instance.currentUser!.uid;

    await _db.collection('families').doc(familyId).collection('invites').add(
        {
        'invitedEmail': email,
        'invitedByUid': uid,
        'status': 'pending',
        'createdAt': FieldValue.serverTimestamp(),
        });
  }

  Stream<QuerySnapshot> invitesForEmail(String email){
    return _db.collectionGroup('invites')
        .where('invitedEmail', isEqualTo: email)
        .where('status', isEqualTo: 'pending')
        .snapshots();
  }

  Future<void> acceptInvite({required String inviteDocPath, required String familyId}) async{
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final inviteRef = _db.doc(inviteDocPath);

    await _db.collection('families').doc(familyId).collection('members').doc(uid).set(
        {
          'role': 'member',
          'joinedAt': FieldValue.serverTimestamp(),
          'displayName': FirebaseAuth.instance.currentUser!.displayName ?? '',
          'email': FirebaseAuth.instance.currentUser!.email ?? '',
        });

    await _db.collection('users').doc(uid).set({
      'personalInfo': {'familyId' : familyId}
    }, SetOptions(merge: true));

    await inviteRef.update({'status': 'accepted', 'acceptedAt': FieldValue.serverTimestamp(), 'acceptedByUid': uid});
  }

  Future<void> declineInvite(String inviteDocPath) async {
    await _db.doc(inviteDocPath).update({'status': 'declined', 'respondedAt': FieldValue.serverTimestamp()});
  }

  Future<void> removeMember(String familyId, String memberUid) async {
    await _db.collection('families').doc(familyId).collection('members').doc(memberUid).delete();
    await _db.collection('users').doc(memberUid).set({'personalInfo': {'familyId': FieldValue.delete()}}, SetOptions(merge: true));
  }

  Future<void> changeMemberRole(String familyId, String memberUid, String role) async{
    await _db.collection('families').doc(familyId).collection('members').doc(memberUid).update({'role': role});
  }
  
  Future<int> adminCount(String familyId) async {
    final snap = await _db.collection('families').doc(familyId).collection('members').where('role', isEqualTo: 'admin').get();
    return snap.size;
  }
}