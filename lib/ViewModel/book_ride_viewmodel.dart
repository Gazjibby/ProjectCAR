import 'package:flutter/material.dart';
import 'package:projectcar/Model/user.dart';
import 'package:projectcar/Providers/ride_template_provider.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class BookRideViewModel extends ChangeNotifier {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  String? selectedPickup;
  String? selectedDropoff;
  int? price;
  DateTime? selectedDate;
  TimeOfDay? selectedTime;
  int? numOfPax;

  BuildContext context;
  String rideStatusMessage = '';
  String? activeRideId;

  BookRideViewModel(this.context);

  List<DropdownMenuItem<String>> getPickupItems() {
    final rideTemplates =
        Provider.of<RideTemplateProvider>(context, listen: false).rideTemplates;
    final locations =
        rideTemplates.map((template) => template.pickup).toSet().toList();
    return locations
        .map((location) => DropdownMenuItem<String>(
              value: location,
              child: Text(location),
            ))
        .toList();
  }

  List<DropdownMenuItem<String>> getDropOffItems() {
    final rideTemplates =
        Provider.of<RideTemplateProvider>(context, listen: false).rideTemplates;
    final locations =
        rideTemplates.map((template) => template.dropoff).toSet().toList();
    return locations
        .map((location) => DropdownMenuItem<String>(
              value: location,
              child: Text(location),
            ))
        .toList();
  }

  void updatePrice() {
    final rideTemplateProvider =
        Provider.of<RideTemplateProvider>(context, listen: false);
    final template =
        rideTemplateProvider.getRideTemplate(selectedPickup!, selectedDropoff!);
    price = template?.price;
    notifyListeners();
  }

  String formatTime(TimeOfDay timeOfDay) {
    final String formattedHour = timeOfDay.hour.toString().padLeft(2, '0');
    final String formattedMinute = timeOfDay.minute.toString().padLeft(2, '0');
    return '$formattedHour:$formattedMinute';
  }

  Future<bool> hasActiveRide() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final String userMatricStaffNumber = userProvider.user!.matricStaffNumber;

    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('Ride Request')
        .where('UserRequest', isEqualTo: userMatricStaffNumber)
        .where('Status', whereIn: ['Posted', 'Ongoing', 'Accepted']).get();

    return querySnapshot.docs.isNotEmpty;
  }

  Future<void> fetchRideStatus() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final String userMatricStaffNumber = userProvider.user!.matricStaffNumber;

    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('Ride Request')
        .where('UserRequest', isEqualTo: userMatricStaffNumber)
        .where('Status', whereNotIn: ['Completed', 'Cancelled'])
        .limit(1)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      var rideRequest = querySnapshot.docs.first;
      activeRideId = rideRequest.id;
      String status = rideRequest['Status'];
      if (status == 'Posted') {
        rideStatusMessage = 'Waiting for Driver to accept';
      } else if (status == 'Ongoing') {
        rideStatusMessage = 'Driver has accepted the request';
      } else {
        rideStatusMessage = '';
      }
    } else {
      rideStatusMessage = '';
      activeRideId = null;
    }
    notifyListeners();
  }

  Future<void> cancelRide() async {
    if (activeRideId != null) {
      await FirebaseFirestore.instance
          .collection('Ride Request')
          .doc(activeRideId)
          .update({'Status': 'Cancelled'});

      rideStatusMessage = '';
      activeRideId = null;
      notifyListeners();
    }
  }

  void postRideBooking() {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final String userMatricStaffNumber = userProvider.user!.matricStaffNumber;
    final String userFullName = userProvider.user!.fullName;

    Map<String, dynamic> rideRequestData = {
      'UserRequest': userMatricStaffNumber,
      'UserName': userFullName,
      'DriverAccepted': 'None',
      'Ride Details': {
        'pickupLocation': selectedPickup,
        'dropoffLocation': selectedDropoff,
        'pickupDate':
            '${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}',
        'pickupTime': selectedTime != null ? formatTime(selectedTime!) : '',
        'passengerCount': numOfPax,
        'price': price ?? 0,
      },
      'Status': 'Posted'
    };

    FirebaseFirestore.instance
        .collection('Ride Request')
        .add(rideRequestData)
        .then((value) {
      print('Ride booking posted successfully!');
    }).catchError((error) {
      print('Error posting ride booking: $error');
    });
  }
}
