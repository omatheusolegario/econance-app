import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FamilyService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<String?> getUserFamilyId(String uid) async {
    final snap = await _db.collection('users').doc(uid).get();
    final data = snap.data();
    return data != null && data['personalInfo'] != null
        ? data['personalInfo']['familyId'] as String?
        : null;
  }

  Future<String> createFamily({required String name}) async {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final famRef = await _db.collection('families').add({
      'name': name,
      'createdByUid': uid,
      'createdAt': FieldValue.serverTimestamp(),
    });

    await famRef.collection('members').doc(uid).set({
      'role': 'creator',
      'joinedAt': FieldValue.serverTimestamp(),
      'displayName': FirebaseAuth.instance.currentUser!.displayName ?? '',
      'email': FirebaseAuth.instance.currentUser!.email ?? '',
    });

    await _db.collection('users').doc(uid).set({
      'personalInfo': {'familyId': famRef.id},
    }, SetOptions(merge: true));

    return famRef.id;
  }

  Stream<DocumentSnapshot> familyDocStream(String familyId) {
    return _db.collection('families').doc(familyId).snapshots();
  }

  Stream<QuerySnapshot> membersStream(String familyId) {
    return _db
        .collection('families')
        .doc(familyId)
        .collection('members')
        .snapshots();
  }

  Future<bool> isUserInFamily(String uid) async {
    final userDoc = await _db.collection('users').doc(uid).get();
    if (userDoc.exists) {
      final data = userDoc.data();
      if (data != null &&
          data['personalInfo']['familyId'] != null &&
          data['personalInfo']['familyId'] != '') {
        return true;
      }
    }
    return false;
  }

  Future<bool> inviteByUid({
    required String invitedUid,
    required String familyId,
    required String inviterName,
  }) async {
    final currentUser = FirebaseAuth.instance.currentUser!;
    final alreadyInFamily = await isUserInFamily(invitedUid);

    if (!alreadyInFamily) {
      await _db
          .collection('families')
          .doc(familyId)
          .collection('invites')
          .doc(invitedUid)
          .set({
            'invitedUid': invitedUid,
            'inviterUid': currentUser.uid,
            'inviterName': inviterName,
            'status': 'pending',
            'createdAt': FieldValue.serverTimestamp(),
          });

      return true;
    }
    return false;
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> streamMyInvites() {
    final currentUser = FirebaseAuth.instance.currentUser!;
    return _db
        .collectionGroup('invites')
        .where('invitedUid', isEqualTo: currentUser.uid)
        .where('status', isEqualTo: 'pending')
        .snapshots();
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> streamFamilyPendingInvites(
    String familyId,
  ) {
    return _db
        .collection('families')
        .doc(familyId)
        .collection('invites')
        .snapshots();
  }

  Future<void> respondToInvite(String familyId, bool accept) async {
    final currentUser = FirebaseAuth.instance.currentUser!;
    final inviteRef = _db
        .collection('families')
        .doc(familyId)
        .collection('invites')
        .doc(currentUser.uid);

    final inviteSnap = await inviteRef.get();
    if (!inviteSnap.exists) return;

    if (accept) {
      await _db
          .collection('families')
          .doc(familyId)
          .collection('members')
          .doc(currentUser.uid)
          .set({
            'role': 'member',
            'joinedAt': FieldValue.serverTimestamp(),
            'displayName': currentUser.displayName ?? '',
            'email': currentUser.email ?? '',
          });

      await _db.collection('users').doc(currentUser.uid).set({
        'personalInfo': {'familyId': familyId},
      }, SetOptions(merge: true));
    }
    await inviteRef.update({
      'status': accept ? 'accepted' : 'declined',
      'respondedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> removeMember(
    String familyId,
    String memberUid,
    bool isLastMember,
  ) async {
    await FirebaseFirestore.instance.collection('users').doc(memberUid).set({
      'personalInfo': {'familyId': FieldValue.delete()},
    }, SetOptions(merge: true));

    if (isLastMember) {
      final membersSnap = await _db
          .collection('families')
          .doc(familyId)
          .collection('members')
          .get();
      for (var doc in membersSnap.docs) {
        await doc.reference.delete();
      }
      final invitesSnap = await _db
          .collection('families')
          .doc(familyId)
          .collection('invites')
          .get();
      for (var doc in invitesSnap.docs) {
        await doc.reference.delete();
      }
      await _db.collection('families').doc(familyId).delete();
    } else {
      await _db
          .collection('families')
          .doc(familyId)
          .collection('members')
          .doc(memberUid)
          .delete();
    }
  }

  Future<void> changeMemberRole(
    String familyId,
    String memberUid,
    String role,
  ) async {
    await _db
        .collection('families')
        .doc(familyId)
        .collection('members')
        .doc(memberUid)
        .update({'role': role});
  }

  Future<int> adminCount(String familyId) async {
    final snap = await _db
        .collection('families')
        .doc(familyId)
        .collection('members')
        .where('role', isEqualTo: 'admin')
        .get();
    return snap.size;
  }

  Future<int> memberCount(String familyId) async {
    final snap = await _db
        .collection('families')
        .doc(familyId)
        .collection('members')
        .get();
    return snap.size;
  }
}
