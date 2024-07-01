import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ManageUserViewModel extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<QuerySnapshot> getUsersStream() {
    return _firestore.collection('users').snapshots();
  }

  Future<void> updateUser(String documentId, Map<String, dynamic> data) async {
    try {
      await _firestore.collection('users').doc(documentId).update(data);
    } catch (e) {
      print('Error updating user: $e');
    }
  }

  Future<void> deleteUser(String documentId) async {
    try {
      await _firestore.collection('users').doc(documentId).delete();
    } catch (e) {
      print('Error deleting user: $e');
    }
  }
}
