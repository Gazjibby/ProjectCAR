import 'package:flutter/material.dart';
import 'package:projectcar/Model/user.dart';
import 'package:projectcar/Providers/ride_template_provider.dart';
import 'package:projectcar/Utils/notifications.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class BookRideViewModel extends ChangeNotifier {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  String? selectedPickup;
  String? selectedDropoff;
  String? pickupLocation;
  String? dropoffLocation;
  String? driverdetail;
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
        .where('Status', whereNotIn: [
          'Completed',
          'Cancelled',
          'Cancelled By User',
          'Cancelled By Driver'
        ])
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
      driverdetail = rideRequest['DriverAccepted'];
    } else {
      rideStatusMessage = '';
      activeRideId = null;
    }
    notifyListeners();
  }

  Future<void> cancelRide() async {
    if (activeRideId != null) {
      try {
        await FirebaseFirestore.instance
            .collection('Ride Request')
            .doc(activeRideId)
            .update({'Status': 'Cancelled By User'});

        QuerySnapshot rideLogQuerySnapshot = await FirebaseFirestore.instance
            .collection('Ride Log')
            .where('rideReqID', isEqualTo: activeRideId)
            .get();

        DateTime now = DateTime.now();
        String formattedTimestamp =
            DateFormat('yyyy-MM-dd HH:mm:ss').format(now);

        for (var doc in rideLogQuerySnapshot.docs) {
          await FirebaseFirestore.instance
              .collection('Ride Log')
              .doc(doc.id)
              .update({
            'StatusHistory': FieldValue.arrayUnion([
              {
                'Status': 'User Cancel Ride Request',
                'UpTime': formattedTimestamp,
              }
            ])
          });
        }

        DocumentSnapshot rideRequestSnapshot = await FirebaseFirestore.instance
            .collection('Ride Request')
            .doc(activeRideId)
            .get();

        if (rideRequestSnapshot.exists) {
          final rideRequestData =
              rideRequestSnapshot.data() as Map<String, dynamic>;
          final driverId = rideRequestData['driverAccepted'];

          final userQuerySnapshot = await FirebaseFirestore.instance
              .collection('drivers')
              .where('matricStaffNumber', isEqualTo: driverId)
              .limit(1)
              .get();

          if (userQuerySnapshot.docs.isNotEmpty) {
            final driverDoc = userQuerySnapshot.docs.first;
            final String? driverToken = driverDoc['driverTokenFCM'];

            if (driverToken != null) {
              final notificationService = NotificationService();
              await notificationService.sendNotification(driverToken,
                  'Ride Cancelled', 'The user has cancelled the ride request.');
            }
          } else {
            print('Driver with MatricStaffNo not found.');
          }
        } else {
          print('Ride request not found.');
        }

        rideStatusMessage = '';
        activeRideId = null;
        notifyListeners();
      } catch (e) {
        print('Failed to cancel ride: $e');
      }
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

      DateTime now = DateTime.now();
      String formattedTimestamp = DateFormat('yyyy-MM-dd HH:mm:ss').format(now);
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

      DateTime now = DateTime.now();
      String formattedTimestamp = DateFormat('yyyy-MM-dd HH:mm:ss').format(now);

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

  Future<void> showRatingDialog() async {
    int rating = 1;
    TextEditingController commentController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              title: const Text('Rate the Driver'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Please rate the driver:'),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(5, (index) {
                      return IconButton(
                        icon: Icon(
                          index < rating ? Icons.star : Icons.star_border,
                        ),
                        color: Colors.amber,
                        onPressed: () {
                          setState(() {
                            rating = index + 1;
                          });
                        },
                      );
                    }),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: commentController,
                    decoration: const InputDecoration(
                      labelText: 'Comments',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 3,
                  ),
                ],
              ),
              actions: [
                TextButton(
                  child: const Text('Cancel'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                ElevatedButton(
                  child: const Text('Submit'),
                  onPressed: () async {
                    if (activeRideId != null) {
                      final rideDetails = await FirebaseFirestore.instance
                          .collection('Ride Request')
                          .doc(activeRideId)
                          .get();

                      String driverName = rideDetails['DriverAccepted'];
                      String comment = commentController.text.trim().isEmpty
                          ? ''
                          : commentController.text.trim();

                      await FirebaseFirestore.instance
                          .collection('Driver Ratings')
                          .add({
                        'rideReqID': activeRideId,
                        'driverMatricStaffNumber': driverName,
                        'rating': rating,
                        'comments': comment,
                        'timestamp': FieldValue.serverTimestamp(),
                      });

                      await confirmcompleteRide();
                    }
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );
      },
    );
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

  void showDetails(BuildContext context) async {
    final driverId = driverdetail;

    try {
      DocumentSnapshot rideSnapshot = await FirebaseFirestore.instance
          .collection('Ride Request')
          .doc(activeRideId)
          .get();
      var rideData = rideSnapshot.data() as Map<String, dynamic>?;

      QuerySnapshot driverQuerySnapshot = await FirebaseFirestore.instance
          .collection('drivers')
          .where('matricStaffNumber', isEqualTo: driverId)
          .limit(1)
          .get();

      var driverData = driverQuerySnapshot.docs.isNotEmpty
          ? driverQuerySnapshot.docs.first.data() as Map<String, dynamic>?
          : null;

      if (rideData != null && driverData != null) {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Ride and Driver Details'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                      'Pickup Location: ${rideData['Ride Details']['pickupLocation']}'),
                  Text(
                      'Dropoff Location: ${rideData['Ride Details']['dropoffLocation']}'),
                  Text(
                      'Pickup Time: ${rideData['Ride Details']['pickupTime']}'),
                  Text('Price: RM ${rideData['Ride Details']['price']}'),
                  const SizedBox(height: 20),
                  Text('Driver Name: ${driverData['fullName']}'),
                  Text(
                      'Car: ${driverData['Car Details']['carBrand']} ${driverData['Car Details']['carModel']}'),
                  Text('Car Color: ${driverData['Car Details']['carColor']}'),
                  Text(
                      'Plate Number: ${driverData['Car Details']['plateNumber']}'),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('Close'),
                ),
              ],
            );
          },
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Failed to load ride or driver details')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching details: $e')),
      );
    }
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
}
