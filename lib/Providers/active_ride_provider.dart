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
        .where('Status', whereIn: ['Ongoing', 'Active']).get();

    if (result.docs.isNotEmpty) {
      _activeRide = ActiveRideModel.fromMap(
          result.docs.first.data() as Map<String, dynamic>,
          result.docs.first.id);
    } else {
      _activeRide = null;
    }

    notifyListeners();
  }

  Future<void> confirmPassengerPickup() async {
    if (_activeRide != null) {
      try {
        await FirebaseFirestore.instance
            .collection('Ride Request')
            .doc(_activeRide!.rideID)
            .update({'Status': 'Active'});

        final rideLogQuerySnapshot = await FirebaseFirestore.instance
            .collection('Ride Log')
            .where('rideReqID', isEqualTo: _activeRide!.rideID)
            .get();

        for (var doc in rideLogQuerySnapshot.docs) {
          await FirebaseFirestore.instance
              .collection('Ride Log')
              .doc(doc.id)
              .update({
            'StatusHistory': FieldValue.arrayUnion([
              {
                'Status': 'Passenger Pickup Confirmed, in progress',
                'UpTime': FieldValue.serverTimestamp(),
              }
            ])
          });
        }

        await fetchActiveRide(_activeRide!.driverAccepted);

        notifyListeners();
      } catch (e) {
        print('Failed to confirm pickup: $e');
      }
    }
  }

  Future<void> completeRide() async {
    if (_activeRide != null) {
      try {
        await FirebaseFirestore.instance
            .collection('Ride Request')
            .doc(_activeRide!.rideID)
            .update({'Status': 'Ride Complete, waiting user confirmation'});

        final rideLogQuerySnapshot = await FirebaseFirestore.instance
            .collection('Ride Log')
            .where('rideReqID', isEqualTo: _activeRide!.rideID)
            .get();

        for (var doc in rideLogQuerySnapshot.docs) {
          await FirebaseFirestore.instance
              .collection('Ride Log')
              .doc(doc.id)
              .update({
            'StatusHistory': FieldValue.arrayUnion([
              {
                'Status': 'Ride Complete, waiting user confirmation',
                'UpTime': FieldValue.serverTimestamp(),
              }
            ])
          });
        }

        await fetchActiveRide(_activeRide!.driverAccepted);

        notifyListeners();
      } catch (e) {
        print('Failed to complete ride: $e');
      }
    }
  }
}
