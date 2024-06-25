import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:projectcar/Model/admin_ride_history.dart';
import 'package:projectcar/Model/user.dart';
import 'package:projectcar/Model/driver.dart';

class RideHistoryProvider with ChangeNotifier {
  List<AdminRideHistoryModel> _rideHistoryList = [];
  bool _isLoading = true;

  List<AdminRideHistoryModel> get rideHistoryList => _rideHistoryList;
  bool get isLoading => _isLoading;

  RideHistoryProvider() {
    fetchRideHistory();
  }

  Future<void> fetchRideHistory() async {
    _isLoading = true;
    notifyListeners();

    List<AdminRideHistoryModel> rideHistoryList = [];

    try {
      QuerySnapshot rideHistorySnapshot =
          await FirebaseFirestore.instance.collection('Ride Request').get();

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

        String userRequest = data['UserRequest'];
        QuerySnapshot userSnapshot = await FirebaseFirestore.instance
            .collection('users')
            .where('MatricStaffNo', isEqualTo: userRequest)
            .get();

        if (userSnapshot.docs.isEmpty) {
          continue;
        }

        UserModel user = UserModel.fromMap(
            userSnapshot.docs.first.data() as Map<String, dynamic>);

        String driverAccepted = data['DriverAccepted'];
        QuerySnapshot driverSnapshot = await FirebaseFirestore.instance
            .collection('drivers')
            .where('matricStaffNumber', isEqualTo: driverAccepted)
            .get();

        if (driverSnapshot.docs.isEmpty) {
          continue;
        }

        DriverModel driver = DriverModel.fromMap(
            driverSnapshot.docs.first.data() as Map<String, dynamic>);

        AdminRideHistoryModel rideHistory =
            AdminRideHistoryModel.fromMap(data, statusHistory, user, driver);
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
