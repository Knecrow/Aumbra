import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/user_model.dart';
import '../models/history_entry.dart';
import 'package:firebase_core/firebase_core.dart';

class FirebaseService {
  FirebaseAuth? get _auth => Firebase.apps.isNotEmpty ? FirebaseAuth.instance : null;
  GoogleSignIn? _googleSignInInstance;
  GoogleSignIn get _googleSignIn => _googleSignInInstance ??= GoogleSignIn();
  FirebaseFirestore? get _firestore => Firebase.apps.isNotEmpty ? FirebaseFirestore.instance : null;

  User? get currentUser => _auth?.currentUser;
  bool get isSignedIn => _auth?.currentUser != null;

  Stream<User?> get authStateChanges => _auth?.authStateChanges() ?? const Stream.empty();

  // ─── AUTHENTICATION ──────────────────────────────────────────────────────

  Future<User?> signInWithGoogle() async {
    try {
      if (kIsWeb && Firebase.apps.isEmpty) {
        return null;
      }
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
      debugPrint('Google Sign-in error: $e');
      return null;
    }
  }

  Future<void> signOut() async {
    try {
      await _googleSignInInstance?.signOut();
      await _auth?.signOut();
    } catch (e) {
      debugPrint('Sign out error: $e');
    }
  }

  // ─── USER DATA ──────────────────────────────────────────────────────────

  Future<void> pushToCloud(UserModel user) async {
    final uid = _auth?.currentUser?.uid;
    if (uid == null || _firestore == null) return;

    try {
      await _firestore!
          .collection('users')
          .doc(uid)
          .set(user.toMap(), SetOptions(merge: true));
    } catch (e) {
      debugPrint('Cloud sync push error: $e');
    }
  }

  Future<UserModel?> pullFromCloud(String localUid) async {
    final uid = _auth?.currentUser?.uid;
    if (uid == null || _firestore == null) return null;

    try {
      final doc = await _firestore!.collection('users').doc(uid).get();
      if (!doc.exists || doc.data() == null) return null;

      return UserModel.fromMap(doc.data()!);
    } catch (e) {
      debugPrint('Cloud sync pull error: $e');
      return null;
    }
  }

  // ─── HISTORY DATA ────────────────────────────────────────────────────────

  Future<void> pushHistoryToCloud(HistoryEntry entry) async {
    final uid = _auth?.currentUser?.uid;
    if (uid == null || _firestore == null) return;

    try {
      await _firestore!
          .collection('users')
          .doc(uid)
          .collection('history')
          .doc(entry.id)
          .set(entry.toMap());
    } catch (e) {
      debugPrint('History push error: $e');
    }
  }

  Future<List<HistoryEntry>> pullHistoryFromCloud() async {
    final uid = _auth?.currentUser?.uid;
    if (uid == null || _firestore == null) return [];

    try {
      final snapshot = await _firestore!
          .collection('users')
          .doc(uid)
          .collection('history')
          .orderBy('completed_date', descending: true)
          .get();

      return snapshot.docs.map((doc) => HistoryEntry.fromMap(doc.data())).toList();
    } catch (e) {
      debugPrint('History pull error: $e');
      return [];
    }
  }

  // ─── DELETE CLOUD DATA ───────────────────────────────────────────────────

  Future<void> deleteCloudData() async {
    final uid = _auth?.currentUser?.uid;
    if (uid == null || _firestore == null) return;

    try {
      // Delete history subcollection
      final historyDocs = await _firestore!
          .collection('users')
          .doc(uid)
          .collection('history')
          .get();

      for (final doc in historyDocs.docs) {
        await doc.reference.delete();
      }

      // Delete user document
      await _firestore!.collection('users').doc(uid).delete();
    } catch (e) {
      debugPrint('Cloud delete error: $e');
    }
  }

  Future<void> syncUserToCloud(UserModel user) async => pushToCloud(user);
  Future<void> saveHistoryEntry(HistoryEntry entry) async => pushHistoryToCloud(entry);
  Future<void> deleteUserFromFirestore(String uid) async => deleteCloudData();
}
