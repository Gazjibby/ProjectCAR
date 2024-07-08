import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminHomeViewModel with ChangeNotifier {
  bool _isFetched = false;
  bool get isFetched => _isFetched;

  Future<int> getDriverApplicantsCount() async {
    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('drivers')
        .where('status', isEqualTo: 'pending')
        .get();
    return snapshot.size;
  }

  Future<int> getActiveDriversCount() async {
    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('drivers')
        .where('status', isEqualTo: 'Active')
        .get();
    return snapshot.size;
  }

  Future<int> getPostedRideReq() async {
    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('Ride Request')
        .where('Status', isEqualTo: 'Posted')
        .get();
    return snapshot.size;
  }

  Future<int> getOngoingRideReq() async {
    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('Ride Request')
        .where('Status', isEqualTo: 'Ongoing')
        .get();
    return snapshot.size;
  }

  Future<int> getCompleteRideReq() async {
    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('Ride Request')
        .where('Status', isEqualTo: 'Completed')
        .get();
    return snapshot.size;
  }

  Future<int> getUsersCount() async {
    QuerySnapshot snapshot =
        await FirebaseFirestore.instance.collection('users').get();
    return snapshot.size;
  }

  void setFetched(bool fetched) {
    _isFetched = fetched;
    notifyListeners();
  }
}
