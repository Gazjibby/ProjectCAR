import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:projectcar/Model/user.dart';
import 'package:projectcar/Providers/ride_template_provider.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;

class BookRideViewModel extends ChangeNotifier {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  String? selectedPickup;
  String? selectedDropoff;
  String? pickupLocation;
  String? dropoffLocation;
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
    final locations = rideTemplates
        .map((template) => template.pickupPointName)
        .toSet()
        .toList();
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
    final locations = rideTemplates
        .map((template) => template.dropoffPointName)
        .toSet()
        .toList();
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
        .where('Status', whereIn: [
      'Posted',
      'Ongoing',
      'Accepted',
      'Active',
      'Ride Complete, waiting user confirmation'
    ]).get();

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
      } else if (status == 'Active') {
        rideStatusMessage = 'Heading to drop off location';
      } else if (status == 'Ride Complete, waiting user confirmation') {
        rideStatusMessage = 'Confirm Ride Completion';
      } else {
        rideStatusMessage = '';
      }
      pickupLocation = rideRequest['Ride Details']['pickupLocation'];
      dropoffLocation = rideRequest['Ride Details']['dropoffLocation'];
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

  void postRideBooking() async {
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
      print('Ride booking posted successfully! Document ID: ${value.id}');

      String rideReqID = value.id;

      String formattedTimestamp = DateTime.now().toIso8601String();
      Map<String, dynamic> initialRideLogData = {
        'rideReqID': rideReqID,
        'UserRequest': userMatricStaffNumber,
        'DriverAccepted': 'None',
        'StatusHistory': [
          {
            'Status': 'User Posted',
            'UpTime': formattedTimestamp,
          }
        ]
      };

      FirebaseFirestore.instance
          .collection('Ride Log')
          .add(initialRideLogData)
          .then((rideLogValue) {
        print('Ride log added successfully! Document ID: ${rideLogValue.id}');
      }).catchError((error) {
        print('Error adding ride log: $error');
      });
    }).catchError((error) {
      print('Error posting ride booking: $error');
    });
  }

  Future<void> confirmcompleteRide() async {
    if (activeRideId != null) {
      await FirebaseFirestore.instance
          .collection('Ride Request')
          .doc(activeRideId)
          .update({'Status': 'Completed'});

      String formattedTimestamp = DateTime.now().toIso8601String();

      QuerySnapshot rideLogQuerySnapshot = await FirebaseFirestore.instance
          .collection('Ride Log')
          .where('rideReqID', isEqualTo: activeRideId)
          .get();

      for (var doc in rideLogQuerySnapshot.docs) {
        await FirebaseFirestore.instance
            .collection('Ride Log')
            .doc(doc.id)
            .update({
          'StatusHistory': FieldValue.arrayUnion([
            {
              'Status': 'User confirm completion',
              'UpTime': formattedTimestamp,
            }
          ])
        });
      }
      rideStatusMessage = '';
      activeRideId = null;
      notifyListeners();
    }
  }

  void showConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Booking Details'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (selectedPickup != null && selectedDropoff != null)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Pickup Location: $selectedPickup'),
                      Text('Dropoff Location: $selectedDropoff'),
                      Text(
                          'Pickup Date: ${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}'),
                      Text('Pickup Time: ${selectedTime!.format(context)}'),
                      Text('Passenger Count: $numOfPax'),
                      if (price != null)
                        Text(
                          'Price: RM$price',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                      const SizedBox(height: 16),
                    ],
                  ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton(
              onPressed: () {
                postRideBooking();
                Navigator.of(context).pop();
              },
              child: const Text('Confirm Booking'),
            ),
          ],
        );
      },
    );
  }

  void showBookingForm(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Book Ride'),
          content: SizedBox(
            height: 370,
            child: Form(
              key: formKey,
              child: SingleChildScrollView(
                child: Column(
                  children: <Widget>[
                    DropdownButtonFormField<String>(
                      decoration:
                          const InputDecoration(labelText: 'Pickup Location'),
                      items: getPickupItems(),
                      value: selectedPickup,
                      onChanged: (value) {
                        selectedPickup = value;
                        updatePrice();
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please select a pickup location';
                        }
                        return null;
                      },
                    ),
                    DropdownButtonFormField<String>(
                      decoration:
                          const InputDecoration(labelText: 'Dropoff Location'),
                      items: getDropOffItems(),
                      value: selectedDropoff,
                      onChanged: (value) {
                        selectedDropoff = value;
                        updatePrice();
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please select a dropoff location';
                        }
                        return null;
                      },
                    ),
                    TextFormField(
                      decoration: const InputDecoration(
                          labelText: 'Number of Passengers'),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter the number of passengers';
                        }
                        final number = int.tryParse(value);
                        if (number == null || number <= 0) {
                          return 'Please enter a valid number of passengers';
                        }
                        return null;
                      },
                      onChanged: (value) {
                        numOfPax = int.tryParse(value);
                      },
                    ),
                    TextFormField(
                      decoration:
                          const InputDecoration(labelText: 'Select Date'),
                      readOnly: true,
                      onTap: () async {
                        DateTime? pickedDate = await showDatePicker(
                          context: context,
                          initialDate: selectedDate ?? DateTime.now(),
                          firstDate: DateTime.now(),
                          lastDate:
                              DateTime.now().add(const Duration(days: 365)),
                        );
                        if (pickedDate != null) {
                          selectedDate = pickedDate;
                        }
                      },
                      validator: (value) {
                        if (selectedDate == null) {
                          return 'Please select a date';
                        }
                        return null;
                      },
                      controller: TextEditingController(
                          text: selectedDate != null
                              ? '${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}'
                              : ''),
                    ),
                    TextFormField(
                      decoration:
                          const InputDecoration(labelText: 'Select Time'),
                      readOnly: true,
                      onTap: () async {
                        TimeOfDay? pickedTime = await showTimePicker(
                          context: context,
                          initialTime: selectedTime ?? TimeOfDay.now(),
                        );
                        if (pickedTime != null) {
                          selectedTime = pickedTime;
                        }
                      },
                      validator: (value) {
                        if (selectedTime == null) {
                          return 'Please select a time';
                        }
                        return null;
                      },
                      controller: TextEditingController(
                          text: selectedTime != null
                              ? selectedTime!.format(context)
                              : ''),
                    ),
                  ],
                ),
              ),
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton(
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  formKey.currentState!.save();
                  Navigator.of(context).pop();
                  showConfirmation(context);
                }
              },
              child: const Text('Book Ride'),
            ),
          ],
        );
      },
    );
  }

  /* Future<List<LatLng>> drawRoute(
      String pickupLocation, String dropoffLocation) async {
    final rideTemplateProvider =
        Provider.of<RideTemplateProvider>(context, listen: false);
    final selectedRideTemplate =
        rideTemplateProvider.getRideTemplate(pickupLocation, dropoffLocation);

    if (selectedRideTemplate == null) {
      print('Selected ride template is null');
      return [];
    }

    final pickupLatitude = selectedRideTemplate.pickupLat;
    final pickupLongitude = selectedRideTemplate.pickupLng;
    final dropoffLatitude = selectedRideTemplate.dropoffLat;
    final dropoffLongitude = selectedRideTemplate.dropoffLng;

    final apiUrl = 'https://router.project-osrm.org/route/v1/driving/'
        '$pickupLongitude,$pickupLatitude;$dropoffLongitude,$dropoffLatitude?overview=full';

    final response = await http.get(Uri.parse(apiUrl));

    if (response.statusCode == 200) {
      final decodedResponse =
          json.decode(response.body) as Map<String, dynamic>;
      final routes = decodedResponse['routes'] as List?;
      if (routes != null && routes.isNotEmpty) {
        final geometry = routes[0]['geometry'] as Map<String, dynamic>;
        final routePoints = geometry['coordinates'] as List?;
        if (routePoints != null) {
          final polylinePoints =
              routePoints.map((point) => LatLng(point[1], point[0])).toList();
          print(
              'Route drawn from ($pickupLatitude, $pickupLongitude) to ($dropoffLatitude, $dropoffLongitude)');
          return polylinePoints;
        } else {
          print('Route points not found in the response');
          return [];
        }
      } else {
        print('Routes not found in the response');
        return [];
      }
    } else {
      print(
          'Failed to fetch route from OSRM API. Status code: ${response.statusCode}');
      return [];
    }
  } */
}
