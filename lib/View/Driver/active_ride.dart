import 'package:flutter/material.dart';
import 'package:projectcar/Model/active_ride.dart';
import 'package:projectcar/Model/driver.dart';
import 'package:projectcar/Providers/active_ride_provider.dart';
import 'package:projectcar/Utils/colours.dart';
import 'package:projectcar/ViewModel/active_ride_viewmodel.dart';
import 'package:projectcar/Utils/location.dart';
import 'package:provider/provider.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_map_location_marker/flutter_map_location_marker.dart';

class ActiveRide extends StatefulWidget {
  const ActiveRide({super.key});

  @override
  State<ActiveRide> createState() => _ActiveRideState();
}

class _ActiveRideState extends State<ActiveRide> {
  LocationService? _locationService;

  @override
  void initState() {
    super.initState();
    _initializeActiveRide();
  }

  void _initializeActiveRide() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final driverProvider =
          Provider.of<DriverProvider>(context, listen: false);
      final activeRideViewModel =
          Provider.of<ActiveRideViewModel>(context, listen: false);

      if (driverProvider.driver != null) {
        activeRideViewModel
            .fetchActiveRide(driverProvider.driver!.matricStaffNumber);
      }
    });
  }

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
    return Scaffold(
      body: Consumer2<ActiveRideProvider, ActiveRideViewModel>(
        builder: (context, provider, viewModel, child) {
          if (provider.activeRide == null) {
            return const Center(child: Text('No active ride.'));
          } else {
            final activeRide = provider.activeRide!;
            final displayText = activeRide.status == 'Active'
                ? 'Head to ${activeRide.dropoffLocation}'
                : 'Head to ${activeRide.pickupLocation} by ${activeRide.pickupTime}';

            _locationService = LocationService(activeRide.driverAccepted);

            return Stack(
              children: [
                FlutterMap(
                  options: const MapOptions(
                    initialCenter:
                        LatLng(1.558877361245217, 103.63759771629142),
                    initialZoom: 15.0,
                  ),
                  children: [
                    TileLayer(
                      urlTemplate:
                          'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.example.app',
                    ),
                    CurrentLocationLayer(
                      alignPositionOnUpdate: AlignOnUpdate.always,
                      alignDirectionOnUpdate: AlignOnUpdate.never,
                      style: const LocationMarkerStyle(
                        marker: DefaultLocationMarker(),
                        markerSize: Size(10, 10),
                        markerDirection: MarkerDirection.heading,
                      ),
                    ),
                    MarkerLayer(
                      markers: [
                        if (viewModel.pickupLocation != null)
                          Marker(
                            width: 40,
                            height: 40,
                            point: viewModel.pickupLocation!,
                            child: const Icon(
                              Icons.location_on,
                              color: Colors.green,
                              size: 40,
                            ),
                          ),
                        if (viewModel.dropoffLocation != null)
                          Marker(
                            width: 40,
                            height: 40,
                            point: viewModel.dropoffLocation!,
                            child: const Icon(
                              Icons.location_on,
                              color: Colors.red,
                              size: 40,
                            ),
                          )
                      ],
                    ),
                    PolylineLayer(
                      polylines: [
                        Polyline(
                          points: viewModel.polyLinePoints,
                          color: Colors.blue,
                          strokeWidth: 4.0,
                        ),
                      ],
                    ),
                  ],
                ),
                Positioned(
                  top: 16.0,
                  left: 16.0,
                  right: 16.0,
                  child: Material(
                    elevation: 4,
                    borderRadius: BorderRadius.circular(12),
                    color: AppColors.uniPeach,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            displayText,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    title: const Text('Cancel Ride'),
                                    content: const Text(
                                        'Are you sure you want to cancel the ride request?'),
                                    actions: <Widget>[
                                      TextButton(
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                        },
                                        child: const Text('No'),
                                      ),
                                      TextButton(
                                        onPressed: () {
                                          provider.cancelRide();
                                          Navigator.of(context).pop();
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            const SnackBar(
                                              content: Text(
                                                  'Ride request has been cancelled.'),
                                            ),
                                          );
                                        },
                                        child: const Text('Yes'),
                                      ),
                                    ],
                                  );
                                },
                              );
                            },
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
                Align(
                  alignment: Alignment.bottomLeft,
                  child: Padding(
                    padding: const EdgeInsets.all(15.0),
                    child: FloatingActionButton(
                      onPressed: () {
                        viewModel.showQrCodeDialog(context);
                      },
                      backgroundColor: AppColors.uniMaroon,
                      foregroundColor: AppColors.uniPeach,
                      child: const Icon(Icons.qr_code),
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Padding(
                    padding: const EdgeInsets.all(15.0),
                    child: SizedBox(
                      width: 200,
                      child: FloatingActionButton(
                        onPressed: () {
                          if (activeRide.status != 'Active') {
                            provider.confirmPassengerPickup();
                          } else {
                            provider.completeRide();
                          }
                        },
                        backgroundColor: activeRide.status != 'Active'
                            ? Colors.greenAccent
                            : Colors.greenAccent,
                        foregroundColor: Colors.white,
                        child: Text(
                          activeRide.status != 'Active'
                              ? 'Confirm Passenger Pickup'
                              : 'Complete Ride Request',
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment.bottomRight,
                  child: Padding(
                    padding: const EdgeInsets.all(15.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        FloatingActionButton(
                          onPressed: () {
                            _initializeActiveRide();
                          },
                          backgroundColor: AppColors.uniMaroon,
                          foregroundColor: AppColors.uniPeach,
                          child: const Icon(Icons.refresh),
                        ),
                        const SizedBox(height: 8.0),
                        FloatingActionButton(
                          onPressed: () {
                            _showRideDetailsDialog(context, activeRide);
                          },
                          backgroundColor: AppColors.uniMaroon,
                          foregroundColor: AppColors.uniPeach,
                          child: const Icon(Icons.info),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          }
        },
      ),
    );
  }
}
