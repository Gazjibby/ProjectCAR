import 'package:flutter/material.dart';
import 'package:projectcar/Model/active_ride.dart';
import 'package:projectcar/Model/driver.dart';
import 'package:projectcar/Providers/active_ride_provider.dart';
import 'package:projectcar/Providers/ride_template_provider.dart';
import 'package:projectcar/Utils/colours.dart';
import 'package:provider/provider.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_map_location_marker/flutter_map_location_marker.dart';
import 'package:projectcar/location.dart';

class ActiveRide extends StatefulWidget {
  const ActiveRide({super.key});

  @override
  State<ActiveRide> createState() => _ActiveRideState();
}

class _ActiveRideState extends State<ActiveRide> {
  //LocationService? _locationService;
  List<LatLng> _polyLinePoints = [];
  LatLng? _pickupLocation;
  LatLng? _dropoffLocation;

  @override
  void initState() {
    super.initState();

    final driverProvider = Provider.of<DriverProvider>(context, listen: false);
    final activeRideProvider =
        Provider.of<ActiveRideProvider>(context, listen: false);

    activeRideProvider
        .fetchActiveRide(driverProvider.driver!.matricStaffNumber)
        .then((_) {
      final activeRide = activeRideProvider.activeRide;
      if (activeRide != null) {
        _loadRoute(activeRide.dropoffLocation, activeRide.pickupLocation);
        _setMarkerLocations(
            activeRide.dropoffLocation, activeRide.pickupLocation);
      }
    });
    /*  _locationService =
        LocationService(driverProvider.driver!.matricStaffNumber); */
  }

  Future<void> _loadRoute(String dropOffLocation, String pickUpLocation) async {
    final pickupLocation = pickUpLocation;
    final dropoffLocation = dropOffLocation;

    final rideTemplateProvider =
        Provider.of<RideTemplateProvider>(context, listen: false);
    final selectedRideTemplate =
        rideTemplateProvider.getRideTemplate(pickupLocation, dropoffLocation);

    final pickupLatitude = selectedRideTemplate?.pickupLat;
    final pickupLongitude = selectedRideTemplate?.pickupLng;
    final dropoffLatitude = selectedRideTemplate?.dropoffLat;
    final dropoffLongitude = selectedRideTemplate?.dropoffLng;

    if (pickupLatitude == null ||
        pickupLongitude == null ||
        dropoffLatitude == null ||
        dropoffLongitude == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to load ride template locations')),
      );
      return;
    }

    final url =
        'http://router.project-osrm.org/route/v1/driving/$pickupLongitude,$pickupLatitude;$dropoffLongitude,$dropoffLatitude?overview=full&geometries=geojson';

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body) as Map<String, dynamic>;
      final routes = jsonResponse['routes'] as List?;
      if (routes != null && routes.isNotEmpty) {
        final routePoints = routes[0]['geometry']['coordinates'] as List?;
        if (routePoints != null) {
          setState(() {
            _polyLinePoints = routePoints
                .map((point) => LatLng(point[1] as double, point[0] as double))
                .toList();
          });
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Route points not found')),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Routes not found')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to fetch route')),
      );
    }
  }

  Future<void> _setMarkerLocations(
      String dropOffLocation, String pickUpLocation) async {
    final pickupLocation = pickUpLocation;
    final dropoffLocation = dropOffLocation;

    final rideTemplateProvider =
        Provider.of<RideTemplateProvider>(context, listen: false);
    final selectedRideTemplate =
        rideTemplateProvider.getRideTemplate(pickupLocation, dropoffLocation);

    if (selectedRideTemplate != null) {
      final pickupLatitude = selectedRideTemplate.pickupLat;
      final pickupLongitude = selectedRideTemplate.pickupLng;
      final dropoffLatitude = selectedRideTemplate.dropoffLat;
      final dropoffLongitude = selectedRideTemplate.dropoffLng;

      double convertpickupLatitude = pickupLatitude.clamp(-90.0, 90.0);
      double convertpickupLongitude = pickupLongitude.clamp(-180.0, 180.0);
      double convertdropoffLatitude = dropoffLatitude.clamp(-90.0, 90.0);
      double convertdropoffLongitude = dropoffLongitude.clamp(-180.0, 180.0);

      setState(() {
        _pickupLocation = LatLng(convertpickupLatitude, convertpickupLongitude);
        _dropoffLocation =
            LatLng(convertdropoffLatitude, convertdropoffLongitude);
      });
    }
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
              final displayText = activeRide.status == 'Active'
                  ? 'Head to ${activeRide.dropoffLocation}'
                  : 'Head to ${activeRide.pickupLocation} by ${activeRide.pickupTime}';

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
                          if (_pickupLocation != null)
                            Marker(
                              width: 40,
                              height: 40,
                              point: _pickupLocation!,
                              child: const Icon(
                                Icons.location_on,
                                color: Colors.green,
                                size: 40,
                              ),
                            ),
                          if (_dropoffLocation != null)
                            Marker(
                              width: 40,
                              height: 40,
                              point: _dropoffLocation!,
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
                            points: _polyLinePoints,
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
                                provider.cancelRide();
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
                        onPressed: () {},
                        backgroundColor: AppColors.uniMaroon,
                        foregroundColor: AppColors.uniPeach,
                        child: const Icon(Icons.my_location),
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
