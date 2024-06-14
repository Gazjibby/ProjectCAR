import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:projectcar/Model/active_ride.dart';
import 'package:intl/intl.dart';
import 'package:projectcar/notifications.dart';

class ActiveRideProvider with ChangeNotifier {
  ActiveRideModel? _activeRide;

  ActiveRideModel? get activeRide => _activeRide;

  DateTime now = DateTime.now();

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
    String formattedTimestamp = DateFormat('yyyy-MM-dd HH:mm:ss').format(now);

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
                'UpTime': formattedTimestamp,
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
    String formattedTimestamp = DateFormat('yyyy-MM-dd HH:mm:ss').format(now);

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
                'UpTime': formattedTimestamp,
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

  Future<void> cancelRide() async {
    String formattedTimestamp =
        DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());

    if (_activeRide != null) {
      try {
        await FirebaseFirestore.instance
            .collection('Ride Request')
            .doc(_activeRide!.rideID)
            .update({'Status': 'Cancelled By Driver'});

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
                'Status': 'Driver Cancel Ride Request',
                'UpTime': formattedTimestamp,
              }
            ])
          });
        }

        final userQuerySnapshot = await FirebaseFirestore.instance
            .collection('users')
            .where('MatricStaffNo', isEqualTo: _activeRide!.userRequest)
            .limit(1)
            .get();

        if (userQuerySnapshot.docs.isNotEmpty) {
          final userDoc = userQuerySnapshot.docs.first;
          final String? userToken = userDoc['userTokenFCM'];

          if (userToken != null) {
            final notificationService = NotificationService();
            await notificationService.sendNotification(
                userToken,
                'Ride Cancelled',
                'Your ride request has been cancelled by the driver.');
          }
        } else {
          print('User with MatricStaffNo not found.');
        }

        await fetchActiveRide(_activeRide!.driverAccepted);

        notifyListeners();
      } catch (e) {
        print('Failed to cancel ride: $e');
      }
    }
  }
}
