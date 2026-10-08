import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Customer profile data stored in Firestore at users/{uid}.
/// Roles should be secured with Firestore security rules, not just app UI.
class UserService {
  UserService._();

  static final UserService instance = UserService._();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  CollectionReference<Map<String, dynamic>> get users =>
      _firestore.collection('users');

  User? get currentUser => _auth.currentUser;
  String? get currentUserId => _auth.currentUser?.uid;

  Future<void> createUserProfile({
    required User user,
    required String name,
  }) async {
    final ref = users.doc(user.uid);
    final existing = await ref.get();
    if (!existing.exists) {
      await ref.set({
        'uid': user.uid,
        'name': name.trim(),
        'email': user.email ?? '',
        'role': 'customer',
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } else {
      // Never overwrite role on an existing document.
      await ref.set({
        'name': name.trim(),
        'email': user.email ?? '',
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    }
  }

  /// Creates a Firestore profile for existing Firebase Auth users if missing.
  Future<void> ensureCurrentUserProfile() async {
    final user = _auth.currentUser;
    if (user == null) {
      throw StateError('No authenticated Firebase user.');
    }

    final ref = users.doc(user.uid);
    final snapshot = await ref.get();

    if (!snapshot.exists) {
      await ref.set({
        'uid': user.uid,
        'name': user.displayName?.trim() ?? '',
        'email': user.email ?? '',
        'role': 'customer',
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
      return;
    }

    final data = snapshot.data() ?? <String, dynamic>{};
    final updates = <String, dynamic>{};
    final newEmail = user.email ?? '';
    final newName = user.displayName?.trim() ?? '';
    if (data['email'] != newEmail) updates['email'] = newEmail;
    if ((data['name']?.toString().trim() ?? '').isEmpty && newName.isNotEmpty) {
      updates['name'] = newName;
    }
    if (!data.containsKey('uid')) updates['uid'] = user.uid;
    if (!data.containsKey('role')) updates['role'] = 'customer';
    if (updates.isNotEmpty) {
      updates['updatedAt'] = FieldValue.serverTimestamp();
      await ref.set(updates, SetOptions(merge: true));
    }
  }

  Future<Map<String, dynamic>?> getCurrentUserData() async {
    final user = _auth.currentUser;
    if (user == null) return null;
    return (await users.doc(user.uid).get()).data();
  }

  Stream<DocumentSnapshot<Map<String, dynamic>>> currentUserStream() {
    final user = _auth.currentUser;
    if (user == null) throw StateError('No logged in user.');
    return users.doc(user.uid).snapshots();
  }

  Stream<DocumentSnapshot<Map<String, dynamic>>> userStream(String uid) =>
      users.doc(uid).snapshots();

  Future<String> getCurrentUserRole() async {
    final data = await getCurrentUserData();
    return data?['role']?.toString().toLowerCase() ?? 'customer';
  }

  Future<bool> isAdmin() async => (await getCurrentUserRole()) == 'admin';

  Future<String> getCurrentUserName() async {
    final data = await getCurrentUserData();
    final name = data?['name']?.toString().trim() ?? '';
    if (name.isNotEmpty) return name;
    final displayName = _auth.currentUser?.displayName?.trim() ?? '';
    return displayName.isNotEmpty ? displayName : 'Flowerbonia Customer';
  }

  Future<void> updateUserName(String name) async {
    final user = _auth.currentUser;
    if (user == null) throw StateError('No logged in user.');
    final clean = name.trim();
    if (clean.isEmpty) throw ArgumentError('Name cannot be empty.');
    await user.updateDisplayName(clean);
    await users.doc(user.uid).set({
      'uid': user.uid,
      'name': clean,
      'email': user.email ?? '',
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }
}
