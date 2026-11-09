import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import '../../models/vocabulary_model.dart';
import '../database/app_database.dart';

class CloudSyncService {
  static final CloudSyncService instance = CloudSyncService._internal();
  CloudSyncService._internal();

  bool get isFirebaseReady => Firebase.apps.isNotEmpty;

  FirebaseAuth? get _auth {
    if (!isFirebaseReady) return null;
    try {
      return FirebaseAuth.instance;
    } catch (_) {
      return null;
    }
  }

  FirebaseFirestore? get _firestore {
    if (!isFirebaseReady) return null;
    try {
      return FirebaseFirestore.instance;
    } catch (_) {
      return null;
    }
  }

  User? get currentUser => _auth?.currentUser;
  Stream<User?> get authStateChanges =>
      _auth?.authStateChanges() ?? const Stream.empty();

  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _vocabSubscription;

  /// Sign In with Email and Password
  Future<UserCredential> signIn(String email, String password) async {
    final auth = _auth;
    if (auth == null) {
      throw Exception('Firebase belum siap. Silakan refresh halaman.');
    }
    return await auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
  }

  /// Register new account with Email and Password
  Future<UserCredential> register(String email, String password) async {
    final auth = _auth;
    if (auth == null) {
      throw Exception('Firebase belum siap. Silakan refresh halaman.');
    }
    return await auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
  }

  /// Sign Out
  Future<void> signOut() async {
    await stopListening();
    await _auth?.signOut();
  }

  /// Reference to the user's vocabularies collection in Firestore
  CollectionReference<Map<String, dynamic>>? _vocabCollection() {
    final fs = _firestore;
    final uid = currentUser?.uid;
    if (fs == null || uid == null) return null;
    return fs.collection('users').doc(uid).collection('vocabularies');
  }

  /// Reference to custom topics document
  DocumentReference<Map<String, dynamic>>? _topicsDoc() {
    final fs = _firestore;
    final uid = currentUser?.uid;
    if (fs == null || uid == null) return null;
    return fs.collection('users').doc(uid).collection('meta').doc('topics');
  }

  /// Start realtime listener for Firestore updates (e.g. added on Laptop -> auto updates on Phone)
  void startListening({
    required Function(List<Vocabulary> cloudVocabs) onRemoteUpdate,
  }) {
    if (!isFirebaseReady) return;
    final col = _vocabCollection();
    if (col == null) return;

    _vocabSubscription?.cancel();
    _vocabSubscription = col.snapshots().listen(
      (snapshot) async {
        final List<Vocabulary> remoteList = [];
        for (final doc in snapshot.docs) {
          final data = doc.data();
          try {
            remoteList.add(Vocabulary.fromMap(data));
          } catch (e) {
            debugPrint('Error parsing Firestore vocab: $e');
          }
        }
        onRemoteUpdate(remoteList);
      },
      onError: (err) {
        debugPrint('Firestore listen error: $err');
      },
    );
  }

  /// Stop listening to Firestore updates
  Future<void> stopListening() async {
    await _vocabSubscription?.cancel();
    _vocabSubscription = null;
  }

  /// Sync single vocabulary to cloud (Upsert)
  Future<void> syncVocabulary(Vocabulary vocab) async {
    if (!isFirebaseReady) return;
    final col = _vocabCollection();
    if (col == null) return;

    try {
      final docId = vocab.word.trim().toLowerCase().replaceAll(RegExp(r'[^a-z0-9_-]'), '_');
      await col.doc(docId).set(vocab.toMap(), SetOptions(merge: true));
    } catch (e) {
      debugPrint('Error syncing vocabulary to cloud: $e');
    }
  }

  /// Delete single vocabulary from cloud
  Future<void> deleteVocabulary(String word) async {
    if (!isFirebaseReady) return;
    final col = _vocabCollection();
    if (col == null) return;

    try {
      final docId = word.trim().toLowerCase().replaceAll(RegExp(r'[^a-z0-9_-]'), '_');
      await col.doc(docId).delete();
    } catch (e) {
      debugPrint('Error deleting vocabulary from cloud: $e');
    }
  }

  /// Upload entire local SQLite database to Firestore
  Future<int> uploadLocalToCloud(List<Vocabulary> localVocabs, List<String> customTopics) async {
    final fs = _firestore;
    final col = _vocabCollection();
    final topicsDoc = _topicsDoc();
    if (fs == null || col == null) {
      throw Exception('Silakan login terlebih dahulu.');
    }

    final batch = fs.batch();
    int count = 0;

    for (final vocab in localVocabs) {
      final docId = vocab.word.trim().toLowerCase().replaceAll(RegExp(r'[^a-z0-9_-]'), '_');
      final ref = col.doc(docId);
      batch.set(ref, vocab.toMap(), SetOptions(merge: true));
      count++;
    }

    if (topicsDoc != null && customTopics.isNotEmpty) {
      batch.set(topicsDoc, {'topics': customTopics}, SetOptions(merge: true));
    }

    await batch.commit();
    return count;
  }

  /// Download all vocabularies from Firestore and merge into local SQLite
  Future<int> downloadCloudToLocal() async {
    final col = _vocabCollection();
    if (col == null) throw Exception('Silakan login terlebih dahulu.');

    final snapshot = await col.get();
    int merged = 0;

    final db = AppDatabase.instance;
    final existing = await db.getAllVocabularies();
    final existingWords = {for (final v in existing) v.word.toLowerCase(): v};

    for (final doc in snapshot.docs) {
      try {
        final remote = Vocabulary.fromMap(doc.data());
        final existingMatch = existingWords[remote.word.toLowerCase()];
        if (existingMatch == null) {
          await db.insertVocabulary(remote);
          merged++;
        } else if (remote.updatedAt.isAfter(existingMatch.updatedAt)) {
          await db.updateVocabulary(remote.copyWith(id: existingMatch.id));
          merged++;
        }
      } catch (e) {
        debugPrint('Error merging remote vocab: $e');
      }
    }

    return merged;
  }
}
