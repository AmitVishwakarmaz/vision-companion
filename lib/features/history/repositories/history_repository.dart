import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:vision_companion/core/constants/app_constants.dart';
import 'package:vision_companion/features/history/models/history_entry.dart';

class HistoryException implements Exception {
  final String message;
  const HistoryException(this.message);

  @override
  String toString() => 'HistoryException: $message';
}

abstract class HistoryRepository {
  /// Logs a generic history entry under users/{uid}/history/{docId}.
  /// If [uid] is omitted, uses the currently signed in Firebase user's UID.
  Future<String> logHistory({
    String? uid,
    required String featureType,
    required String resultSummary,
    Map<String, dynamic>? metadata,
    DateTime? timestamp,
  });

  /// Convenience method to log an object detection result.
  Future<String> logDetection({
    String? uid,
    required String resultSummary,
    Map<String, dynamic>? metadata,
    DateTime? timestamp,
  });

  /// Convenience method to log an AI image analysis result.
  Future<String> logAnalysis({
    String? uid,
    required String resultSummary,
    Map<String, dynamic>? metadata,
    DateTime? timestamp,
  });

  /// Retrieves history entries for the specified [uid] (or current user).
  Future<List<HistoryEntry>> getHistory({
    String? uid,
    int limit = 50,
    String? featureType,
  });

  /// Streams real-time history entries for the specified [uid] (or current user).
  Stream<List<HistoryEntry>> streamHistory({
    String? uid,
    int limit = 50,
    String? featureType,
  });

  /// Deletes a specific history document.
  Future<void> deleteHistoryEntry({
    String? uid,
    required String docId,
  });
}

class FirestoreHistoryRepository implements HistoryRepository {
  final FirebaseFirestore? _firestore;
  final FirebaseAuth? _firebaseAuth;

  FirestoreHistoryRepository({
    this._firestore,
    this._firebaseAuth,
  });

  String _resolveUid(String? uid) {
    final effectiveUid = uid ?? _firebaseAuth?.currentUser?.uid;
    if (effectiveUid == null || effectiveUid.trim().isEmpty) {
      throw const HistoryException('Cannot access history: User is not authenticated.');
    }
    return effectiveUid;
  }

  CollectionReference<Map<String, dynamic>> _historyCollection(String uid) {
    final db = _firestore ?? FirebaseFirestore.instance;
    return db.collection('users').doc(uid).collection('history');
  }

  @override
  Future<String> logHistory({
    String? uid,
    required String featureType,
    required String resultSummary,
    Map<String, dynamic>? metadata,
    DateTime? timestamp,
  }) async {
    final effectiveUid = _resolveUid(uid);
    try {
      final docData = <String, dynamic>{
        'timestamp': timestamp != null
            ? Timestamp.fromDate(timestamp)
            : FieldValue.serverTimestamp(),
        'featureType': featureType,
        'resultSummary': resultSummary,
        'metadata': ?metadata,
      };

      final docRef = await _historyCollection(effectiveUid).add(docData);
      return docRef.id;
    } catch (e) {
      debugPrint('FirestoreHistoryRepository error logging history: $e');
      if (e is HistoryException) rethrow;
      throw HistoryException('Failed to log history: $e');
    }
  }

  @override
  Future<String> logDetection({
    String? uid,
    required String resultSummary,
    Map<String, dynamic>? metadata,
    DateTime? timestamp,
  }) {
    return logHistory(
      uid: uid,
      featureType: AppConstants.featureTypeDetector,
      resultSummary: resultSummary,
      metadata: metadata,
      timestamp: timestamp,
    );
  }

  @override
  Future<String> logAnalysis({
    String? uid,
    required String resultSummary,
    Map<String, dynamic>? metadata,
    DateTime? timestamp,
  }) {
    return logHistory(
      uid: uid,
      featureType: AppConstants.featureTypeAnalyzer,
      resultSummary: resultSummary,
      metadata: metadata,
      timestamp: timestamp,
    );
  }

  @override
  Future<List<HistoryEntry>> getHistory({
    String? uid,
    int limit = 50,
    String? featureType,
  }) async {
    final effectiveUid = _resolveUid(uid);
    try {
      Query<Map<String, dynamic>> query = _historyCollection(effectiveUid)
          .orderBy('timestamp', descending: true);

      if (featureType != null && featureType.isNotEmpty) {
        query = query.where('featureType', isEqualTo: featureType);
      }

      final snapshot = await query.limit(limit).get();
      return snapshot.docs.map((doc) => HistoryEntry.fromFirestore(doc)).toList();
    } catch (e) {
      debugPrint('FirestoreHistoryRepository error fetching history: $e');
      if (e is HistoryException) rethrow;
      throw HistoryException('Failed to fetch history: $e');
    }
  }

  @override
  Stream<List<HistoryEntry>> streamHistory({
    String? uid,
    int limit = 50,
    String? featureType,
  }) {
    final effectiveUid = _resolveUid(uid);
    Query<Map<String, dynamic>> query = _historyCollection(effectiveUid)
        .orderBy('timestamp', descending: true);

    if (featureType != null && featureType.isNotEmpty) {
      query = query.where('featureType', isEqualTo: featureType);
    }

    return query.limit(limit).snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => HistoryEntry.fromFirestore(doc)).toList();
    });
  }

  @override
  Future<void> deleteHistoryEntry({
    String? uid,
    required String docId,
  }) async {
    final effectiveUid = _resolveUid(uid);
    try {
      await _historyCollection(effectiveUid).doc(docId).delete();
    } catch (e) {
      debugPrint('FirestoreHistoryRepository error deleting entry: $e');
      if (e is HistoryException) rethrow;
      throw HistoryException('Failed to delete history entry: $e');
    }
  }
}
