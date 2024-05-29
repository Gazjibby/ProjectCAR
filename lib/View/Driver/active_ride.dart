import 'package:flutter/material.dart';
import 'package:projectcar/Model/active_ride.dart';
import 'package:projectcar/Model/driver.dart';
import 'package:projectcar/Providers/active_ride_provider.dart';
import 'package:projectcar/Utils/colours.dart';
import 'package:provider/provider.dart';

class ActiveRide extends StatefulWidget {
  const ActiveRide({super.key});

  @override
  State<ActiveRide> createState() => _ActiveRideState();
}

class _ActiveRideState extends State<ActiveRide> {
  void _showRideDetailsDialog(
      BuildContext context, ActiveRideModel activeRide) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Ride Details'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('User Request: ${activeRide.userRequest}'),
                Text('Name: ${activeRide.userName}'),
                Text('Pickup Location: ${activeRide.pickupLocation}'),
                Text('Dropoff Location: ${activeRide.dropoffLocation}'),
                Text('Pickup Date: ${activeRide.pickupDate}'),
                Text('Pickup Time: ${activeRide.pickupTime}'),
                Text('Passenger Count: ${activeRide.passengerCount}'),
                Text('Price: RM ${activeRide.price}'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Close'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final driverProvider = Provider.of<DriverProvider>(context);

    return ChangeNotifierProvider(
      create: (_) => ActiveRideProvider()
        ..fetchActiveRide(driverProvider.driver!.matricStaffNumber),
      child: Scaffold(
        appBar: AppBar(title: const Text('Active Ride')),
        body: Consumer<ActiveRideProvider>(
          builder: (context, provider, child) {
            if (provider.activeRide == null) {
              return const Center(child: Text('No active ride.'));
            } else {
              final activeRide = provider.activeRide!;
              return Stack(
                children: [
                  Align(
                    alignment: Alignment.topCenter,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Material(
                        elevation: 4,
                        borderRadius: BorderRadius.circular(12),
                        color: AppColors.uniPeach,
                        child: SizedBox(
                          width: 370,
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Head to ${activeRide.pickupLocation} by ${activeRide.pickupTime}',
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                ElevatedButton(
                                  onPressed: () {},
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.uniMaroon,
                                  ),
                                  child: Text(
                                    'Cancel Ride',
                                    style: TextStyle(
                                      color: AppColors.uniGold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Align(
                    alignment: Alignment.bottomRight,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: FloatingActionButton(
                        onPressed: () {
                          _showRideDetailsDialog(context, activeRide);
                        },
                        backgroundColor: AppColors.uniMaroon,
                        foregroundColor: AppColors.uniPeach,
                        child: const Icon(Icons.info),
                      ),
                    ),
                  ),
                ],
              );
            }
          },
        ),
      ),
    );
  }
}
