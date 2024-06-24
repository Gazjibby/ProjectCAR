import 'package:flutter/material.dart';
import 'package:projectcar/Model/ride_history.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UserRideHistoryViewmodel extends ChangeNotifier {
  List<RideHistoryModel> _rideHistoryList = [];
  bool _isLoading = false;

  List<RideHistoryModel> get rideHistoryList => _rideHistoryList;
  bool get isLoading => _isLoading;

  Future<void> fetchUserRideHistory(String userRequest) async {
    _isLoading = true;
    notifyListeners();

    List<RideHistoryModel> rideHistoryList = [];

    try {
      QuerySnapshot rideHistorySnapshot = await FirebaseFirestore.instance
          .collection('Ride Request')
          .where('UserRequest', isEqualTo: userRequest)
          .get();

      for (var doc in rideHistorySnapshot.docs) {
        var data = doc.data() as Map<String, dynamic>;
        String rideReqID = doc.id;

        QuerySnapshot rideLogSnapshot = await FirebaseFirestore.instance
            .collection('Ride Log')
            .where('rideReqID', isEqualTo: rideReqID)
            .get();

        List<Map<String, String>> statusHistory = [];
        if (rideLogSnapshot.docs.isNotEmpty) {
          var rideLogData =
              rideLogSnapshot.docs.first.data() as Map<String, dynamic>;
          statusHistory = rideLogData['StatusHistory'] != null
              ? List<Map<String, String>>.from(rideLogData['StatusHistory']
                  .map((item) => Map<String, String>.from(item)))
              : [];
        }

        RideHistoryModel rideHistory =
            RideHistoryModel.fromMap(data, statusHistory);
        rideHistoryList.add(rideHistory);
      }
    } catch (e) {
      print('Error fetching ride history: $e');
    }

    _rideHistoryList = rideHistoryList;
    _isLoading = false;
    notifyListeners();
  }
}
