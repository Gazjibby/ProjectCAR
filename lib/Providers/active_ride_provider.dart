import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:projectcar/Model/active_ride.dart';

class ActiveRideProvider with ChangeNotifier {
  ActiveRideModel? _activeRide;

  ActiveRideModel? get activeRide => _activeRide;

  Future<void> fetchActiveRide(String driverId) async {
    final QuerySnapshot result = await FirebaseFirestore.instance
        .collection('Ride Request')
        .where('DriverAccepted', isEqualTo: driverId)
        .where('Status', isEqualTo: "Ongoing")
        .get();

    if (result.docs.isNotEmpty) {
      _activeRide = ActiveRideModel.fromMap(
          result.docs.first.data() as Map<String, dynamic>);
    } else {
      _activeRide = null;
    }

    notifyListeners();
  }
}
