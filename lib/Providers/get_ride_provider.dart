import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:projectcar/Model/ride_request.dart';

class RideProvider with ChangeNotifier {
  FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<RideRequest> _rideRequests = [];

  List<RideRequest> get rideRequests => _rideRequests;

  Future<void> fetchRideRequests() async {
    try {
      QuerySnapshot querySnapshot = await _firestore
          .collection('Ride Request')
          .where('DriverAccepted', isEqualTo: 'None')
          .get();

      _rideRequests = querySnapshot.docs
          .where((doc) =>
              doc['Status'] != 'Completed' && doc['Status'] != 'Cancelled')
          .map((doc) => RideRequest(
                rideReqID: doc.id,
                userRequest: doc['UserRequest'],
                userName: doc['UserName'],
                driverAccepted: doc['DriverAccepted'],
                pickupLocation: doc['Ride Details']['pickupLocation'],
                dropoffLocation: doc['Ride Details']['dropoffLocation'],
                pickupDate: doc['Ride Details']['pickupDate'],
                pickupTime: doc['Ride Details']['pickupTime'],
                passengerCount: doc['Ride Details']['passengerCount'],
                price: doc['Ride Details']['price'],
              ))
          .toList();

      notifyListeners();
    } catch (e) {
      print('Error fetching ride requests: $e');
    }
  }

  Future<bool> hasOngoingRide(
      BuildContext context, String driverMatricStaffNumber) async {
    try {
      final firestore = FirebaseFirestore.instance;

      QuerySnapshot querySnapshot = await firestore
          .collection('Ride Request')
          .where('DriverAccepted', isEqualTo: driverMatricStaffNumber)
          .where('Status',
              whereIn: ['Posted', 'Ongoing', 'Accepted', 'Active']).get();

      List<DocumentSnapshot> documents = querySnapshot.docs;
      if (documents.isNotEmpty) {
        for (var doc in documents) {
          String status = doc['Status'];
          if (status == 'Completed' || status == 'Cancelled') {
            return false;
          }
        }
      }

      return documents.isNotEmpty; // Return true if there are ongoing rides
    } catch (e) {
      print('Error checking ongoing ride: $e');
      return false;
    }
  }
}
