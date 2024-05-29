import 'package:flutter/material.dart';
import 'package:projectcar/Model/driver.dart';
import 'package:projectcar/Providers/active_ride_provider.dart';
import 'package:provider/provider.dart';

class ActiveRide extends StatefulWidget {
  const ActiveRide({super.key});

  @override
  State<ActiveRide> createState() => _ActiveRideState();
}

class _ActiveRideState extends State<ActiveRide> {
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
              return Center(child: const Text('No active ride.'));
            } else {
              final activeRide = provider.activeRide!;
              return Padding(
                padding: const EdgeInsets.all(16.0),
                child: Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16.0),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'User Request: ${activeRide.userRequest}',
                          style: const TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 8.0),
                        Text(
                          'Name: ${activeRide.userName}',
                          style: const TextStyle(fontSize: 18),
                        ),
                        SizedBox(height: 8.0),
                        Text(
                          'Pickup Location: ${activeRide.pickupLocation}',
                          style: const TextStyle(fontSize: 18),
                        ),
                        SizedBox(height: 8.0),
                        Text(
                          'Dropoff Location: ${activeRide.dropoffLocation}',
                          style: const TextStyle(fontSize: 18),
                        ),
                        SizedBox(height: 8.0),
                        Text(
                          'Pickup Date: ${activeRide.pickupDate}',
                          style: const TextStyle(fontSize: 18),
                        ),
                        SizedBox(height: 8.0),
                        Text(
                          'Pickup Time: ${activeRide.pickupTime}',
                          style: const TextStyle(fontSize: 18),
                        ),
                        SizedBox(height: 8.0),
                        Text(
                          'Passenger Count: ${activeRide.passengerCount}',
                          style: const TextStyle(fontSize: 18),
                        ),
                        SizedBox(height: 8.0),
                        Text(
                          'Price: RM ${activeRide.price}',
                          style: const TextStyle(fontSize: 18),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }
          },
        ),
      ),
    );
  }
}

extension DateHelpers on DateTime {
  String toShortString() {
    return "${this.day}/${this.month}/${this.year}";
  }
}
