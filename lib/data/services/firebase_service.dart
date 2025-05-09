import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:journal/data/models/journal_entry.dart';

class FirebaseService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // Authentication
  Future<UserCredential> signInAnonymously() async {
    return await _auth.signInAnonymously();
  }

  Future<UserCredential> signInWithEmailAndPassword(String email, String password) async {
    return await _auth.signInWithEmailAndPassword(email: email, password: password);
  }

  Future<UserCredential> createUserWithEmailAndPassword(String email, String password) async {
    return await _auth.createUserWithEmailAndPassword(email: email, password: password);
  }

  Future<void> signOut() async {
    return await _auth.signOut();
  }

  User? get currentUser => _auth.currentUser;

  // Firestore operations
  Future<void> saveJournalEntry(JournalEntry entry) async {
    if (_auth.currentUser == null) {
      throw Exception('User must be logged in to save journal entries');
    }

    final userId = _auth.currentUser!.uid;
    final entryData = entry.toMap();

    if (entry.id == null) {
      // New entry
      final docRef = _firestore.collection('users').doc(userId).collection('entries').doc();
      entry.id = int.parse(docRef.id);
      entryData['id'] = docRef.id;
      await docRef.set(entryData);
    } else {
      // Update existing entry
      await _firestore.collection('users').doc(userId).collection('entries').doc(entry.id.toString()).update(entryData);
    }
  }

  Future<void> deleteJournalEntry(String entryId) async {
    if (_auth.currentUser == null) {
      throw Exception('User must be logged in to delete journal entries');
    }

    final userId = _auth.currentUser!.uid;
    await _firestore.collection('users').doc(userId).collection('entries').doc(entryId).delete();
  }

  Future<List<JournalEntry>> getJournalEntries() async {
    if (_auth.currentUser == null) {
      throw Exception('User must be logged in to fetch journal entries');
    }

    final userId = _auth.currentUser!.uid;
    final querySnapshot =
        await _firestore.collection('users').doc(userId).collection('entries').orderBy('date', descending: true).get();

    return querySnapshot.docs.map((doc) => JournalEntry.fromMap(doc.data())).toList();
  }

  // Storage operations
  Future<String> uploadImage(File imageFile, String entryId) async {
    if (_auth.currentUser == null) {
      throw Exception('User must be logged in to upload images');
    }

    final userId = _auth.currentUser!.uid;
    final fileName = '${DateTime.now().millisecondsSinceEpoch}_${imageFile.path.split('/').last}';
    final storageRef = _storage.ref().child('users/$userId/entries/$entryId/$fileName');

    final uploadTask = storageRef.putFile(imageFile);
    final snapshot = await uploadTask;
    return await snapshot.ref.getDownloadURL();
  }

  Future<void> deleteImage(String imageUrl) async {
    if (_auth.currentUser == null) {
      throw Exception('User must be logged in to delete images');
    }

    try {
      final ref = _storage.refFromURL(imageUrl);
      await ref.delete();
    } catch (e) {
      throw Exception('Failed to delete image: $e');
    }
  }

  // Sync state
  Stream<QuerySnapshot> entriesStream() {
    if (_auth.currentUser == null) {
      throw Exception('User must be logged in to subscribe to entries');
    }

    final userId = _auth.currentUser!.uid;
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('entries')
        .orderBy('date', descending: true)
        .snapshots();
  }
}
