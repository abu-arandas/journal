import 'dart:async';
import 'package:get/get.dart';
import 'package:journal/data/repositories/journal_repository.dart';
import 'package:journal/data/services/firebase_service.dart';

enum SyncStatus { idle, syncing, success, error }

class CloudSyncController extends GetxController {
  final JournalRepository _journalRepository = Get.find<JournalRepository>();
  final FirebaseService _firebaseService = Get.find<FirebaseService>();

  final RxBool isLoggedIn = false.obs;
  final Rx<SyncStatus> syncStatus = SyncStatus.idle.obs;
  final RxString syncError = ''.obs;
  final RxBool autoSyncEnabled = true.obs;
  StreamSubscription? _entriesSubscription;

  @override
  void onInit() {
    super.onInit();
    checkLoginStatus();
    // Initialize auto-sync if enabled
    if (autoSyncEnabled.value) {
      _setupSync();
    }
  }

  @override
  void onClose() {
    _entriesSubscription?.cancel();
    super.onClose();
  }

  Future<void> checkLoginStatus() async {
    isLoggedIn.value = _firebaseService.currentUser != null;
  }

  Future<void> signInAnonymously() async {
    try {
      await _firebaseService.signInAnonymously();
      isLoggedIn.value = true;
      _setupSync();
    } catch (e) {
      syncError.value = e.toString();
    }
  }

  Future<void> signInWithEmailAndPassword(String email, String password) async {
    try {
      await _firebaseService.signInWithEmailAndPassword(email, password);
      isLoggedIn.value = true;
      _setupSync();
    } catch (e) {
      syncError.value = e.toString();
    }
  }

  Future<void> createAccount(String email, String password) async {
    try {
      await _firebaseService.createUserWithEmailAndPassword(email, password);
      isLoggedIn.value = true;
      _setupSync();
    } catch (e) {
      syncError.value = e.toString();
    }
  }

  Future<void> signOut() async {
    try {
      await _firebaseService.signOut();
      isLoggedIn.value = false;
      _entriesSubscription?.cancel();
      _entriesSubscription = null;
    } catch (e) {
      syncError.value = e.toString();
    }
  }

  Future<void> syncAllEntries() async {
    if (!isLoggedIn.value) {
      syncError.value = 'User not logged in';
      return;
    }

    syncStatus.value = SyncStatus.syncing;

    try {
      // Get all local entries
      final localEntries = await _journalRepository.getAllEntries();

      // Get all cloud entries
      final cloudEntries = await _firebaseService.getJournalEntries();

      // Upload local entries that don't exist in cloud
      for (final localEntry in localEntries) {
        final cloudEntry = cloudEntries.firstWhereOrNull((e) => e.id == localEntry.id);

        if (cloudEntry == null || cloudEntry.updatedAt.isBefore(localEntry.updatedAt)) {
          await _firebaseService.saveJournalEntry(localEntry);
        }
      }

      // Download cloud entries that are newer than local ones
      for (final cloudEntry in cloudEntries) {
        final localEntry = localEntries.firstWhereOrNull((e) => e.id == cloudEntry.id);

        if (localEntry == null || localEntry.updatedAt.isBefore(cloudEntry.updatedAt)) {
          await _journalRepository.saveEntry(cloudEntry);
        }
      }

      syncStatus.value = SyncStatus.success;
    } catch (e) {
      syncStatus.value = SyncStatus.error;
      syncError.value = e.toString();
    }
  }

  void _setupSync() {
    if (!isLoggedIn.value) return;

    // Listen for changes in Firebase
    _entriesSubscription?.cancel();
    _entriesSubscription = _firebaseService.entriesStream().listen(
      (snapshot) async {
        // Only sync if auto-sync is enabled
        if (autoSyncEnabled.value) {
          await syncAllEntries();
        }
      },
      onError: (error) {
        syncStatus.value = SyncStatus.error;
        syncError.value = error.toString();
      },
    );
  }

  void toggleAutoSync(bool value) {
    autoSyncEnabled.value = value;
    if (value) {
      _setupSync();
    } else {
      _entriesSubscription?.cancel();
      _entriesSubscription = null;
    }
  }
}
