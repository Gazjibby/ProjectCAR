import 'package:flutter/material.dart';
import 'package:projectcar/Model/driver.dart';
import 'package:projectcar/Model/ride_request.dart';
import 'package:projectcar/Providers/get_ride_provider.dart';
import 'package:projectcar/Utils/colours.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RideReq extends StatefulWidget {
  const RideReq({Key? key}) : super(key: key);

  @override
  State<RideReq> createState() => _RideReqState();
}

class _RideReqState extends State<RideReq> {
  late BuildContext _dialogContext;

  @override
  void initState() {
    super.initState();
    Provider.of<RideProvider>(context, listen: false).fetchRideRequests();
  }

  @override
  Widget build(BuildContext context) {
    final rideProvider = Provider.of<RideProvider>(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Ride Requests')),
      body: rideProvider.rideRequests.isEmpty
          ? const Center(child: Text('No available Ride Request'))
          : ListView.builder(
              itemCount: rideProvider.rideRequests.length,
              itemBuilder: (context, index) {
                final rideRequest = rideProvider.rideRequests[index];

                return GestureDetector(
                    onTap: () {
                      _showAcceptDialog(context, rideRequest);
                    },
                    child: Card(
                        margin: const EdgeInsets.all(8.0),
                        elevation: 4.0,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16.0)),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: 450,
                                color: AppColors.uniMaroon,
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'User Request: ${rideRequest.userRequest}',
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white),
                                    ),
                                    Text(
                                      'Name: ${rideRequest.userName}',
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                width: 450,
                                color: AppColors.uniPeach,
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const SizedBox(height: 8.0),
                                    Text(
                                        'Pickup Location: ${rideRequest.pickupLocation}'),
                                    Text(
                                        'Dropoff Location: ${rideRequest.dropoffLocation}'),
                                    Text(
                                        'Pickup Date: ${rideRequest.pickupDate}'),
                                    Text(
                                        'Pickup Time: ${rideRequest.pickupTime}'),
                                    Text(
                                        'Passenger Count: ${rideRequest.passengerCount}'),
                                    Text('Price: RM ${rideRequest.price}'),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        )));
              },
            ),
    );
  }

  void _acceptRideRequest(RideRequest rideRequest) async {
    final driverProvider =
        Provider.of<DriverProvider>(_dialogContext, listen: false);
    final String? driverMatricStaffNumber =
        driverProvider.driver?.matricStaffNumber;

    if (driverMatricStaffNumber != null) {
      bool ongoingRide = await Provider.of<RideProvider>(context, listen: false)
          .hasOngoingRide(context, driverMatricStaffNumber);

      if (ongoingRide) {
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
                'You already have an ongoing ride. Please complete it before accepting a new one.'),
          ),
        );
      } else {
        await FirebaseFirestore.instance
            .collection('Ride Request')
            .doc(rideRequest.rideReqID)
            .update({
          'DriverAccepted': driverMatricStaffNumber,
          'Status': 'Ongoing'
        });

        Map<String, dynamic> initialRideLogData = {
          'rideReqID': rideRequest.rideReqID,
          'UserRequest': rideRequest.userRequest,
          'DriverAccepted': driverMatricStaffNumber,
          'StatusHistory': [
            {
              'Status': 'Ongoing',
              'UpTime': FieldValue.serverTimestamp(),
            }
          ]
        };

        await FirebaseFirestore.instance
            .collection('Ride Log')
            .add(initialRideLogData);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Ride request accepted successfully.'),
          ),
        );
      }
    } else {
      print('Driver information not available.');
    }
  }

  void _showAcceptDialog(BuildContext context, RideRequest rideRequest) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        _dialogContext = context; // Store the dialog context
        return AlertDialog(
          title: const Text('Accept Booking?'),
          content: Text(
              'Do you want to accept the booking for ${rideRequest.userName}?'),
          actions: [
            TextButton(
              onPressed: () {
                _acceptRideRequest(rideRequest);
                Navigator.of(context).pop();
              },
              child: const Text('Accept'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Decline'),
            ),
          ],
        );
      },
    );
  }
}
