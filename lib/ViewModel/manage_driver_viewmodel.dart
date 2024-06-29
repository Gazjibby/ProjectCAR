import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';

class ManageDriverViewModel extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<QuerySnapshot> getActiveDriversStream() {
    return _firestore
        .collection('drivers')
        .where('status', isEqualTo: 'Active')
        .snapshots();
  }

  Future<void> updateDriver(
      String documentId, Map<String, dynamic> data) async {
    try {
      await _firestore.collection('drivers').doc(documentId).update(data);
    } catch (e) {
      print('Error updating driver: $e');
    }
  }

  Future<void> deleteDriver(String documentId) async {
    try {
      await _firestore.collection('drivers').doc(documentId).delete();
    } catch (e) {
      print('Error deleting driver: $e');
    }
  }

  Future<void> launchPhotoUrl(Uri url) async {
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      throw 'Could not launch $url';
    }
  }
}
