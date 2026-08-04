import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import '../models/history_entry.dart';

import 'package:firebase_core/firebase_core.dart';

class FirebaseService {
  FirebaseAuth? get _auth => Firebase.apps.isNotEmpty ? FirebaseAuth.instance : null;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  FirebaseFirestore? get _firestore => Firebase.apps.isNotEmpty ? FirebaseFirestore.instance : null;

  User? get currentUser => _auth?.currentUser;
  bool get isSignedIn => _auth?.currentUser != null;

  Stream<User?> get authStateChanges => _auth?.authStateChanges() ?? const Stream.empty();

  // ─── AUTHENTICATION ──────────────────────────────────────────────────────

  Future<User?> signInWithGoogle() async {
    try {
      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null;

      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await _auth?.signInWithCredential(credential);
      return userCredential?.user;
    } catch (e) {
      return null;
    }
  }

  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _auth?.signOut();
  }

  // ─── USER DATA ──────────────────────────────────────────────────────────

  Future<void> saveUserToFirestore(UserModel user) async {
    try {
      await _firestore
          ?.collection('users')
          .doc(user.uid)
          .set(user.toFirestore(), SetOptions(merge: true));
    } catch (e) {
      // Silently fail — offline-first
    }
  }

  Future<UserModel?> getUserFromFirestore(String uid) async {
    try {
      final doc = await _firestore?.collection('users').doc(uid).get();
      if (doc == null || !doc.exists) return null;
      return UserModel.fromMap(doc.data()!);
    } catch (e) {
      return null;
    }
  }

  Future<void> updateUserField(String uid, Map<String, dynamic> fields) async {
    try {
      await _firestore?.collection('users').doc(uid).update(fields);
    } catch (e) {
      // Silently fail
    }
  }

  // ─── HISTORY ─────────────────────────────────────────────────────────────

  Future<void> saveHistoryEntry(HistoryEntry entry) async {
    try {
      await _firestore
          ?.collection('history')
          .doc(entry.id)
          .set(entry.toMap());
    } catch (e) {
      // Silently fail
    }
  }

  Future<List<HistoryEntry>> getHistoryFromFirestore(String userId) async {
    try {
      final snapshot = await _firestore
          ?.collection('history')
          .where('user_id', isEqualTo: userId)
          .orderBy('completed_date', descending: true)
          .get();

      if (snapshot == null) return [];

      return snapshot.docs
          .map((doc) => HistoryEntry.fromMap(doc.data()))
          .toList();
    } catch (e) {
      return [];
    }
  }

  // ─── SYNC ────────────────────────────────────────────────────────────────

  /// Sync local user data to Firestore
  Future<void> syncUserToCloud(UserModel user) async {
    if (!isSignedIn || !user.cloudBackupEnabled) return;
    await saveUserToFirestore(user);
  }

  /// Pull latest data from Firestore (on app start when online)
  Future<UserModel?> pullFromCloud(String uid) async {
    if (!isSignedIn) return null;
    return await getUserFromFirestore(uid);
  }

  Future<void> deleteUserFromFirestore(String uid) async {
    try {
      await _firestore?.collection('users').doc(uid).delete();
      // Delete history
      final historySnap = await _firestore
          ?.collection('history')
          .where('user_id', isEqualTo: uid)
          .get();
      if (historySnap != null) {
        for (final doc in historySnap.docs) {
          await doc.reference.delete();
        }
      }
    } catch (e) {
      // Silently fail
    }
  }
}
