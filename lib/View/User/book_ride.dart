import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:projectcar/Providers/ride_template_provider.dart';
import 'package:projectcar/Utils/colours.dart';
import 'package:projectcar/ViewModel/book_ride_viewmodel.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_map_location_marker/flutter_map_location_marker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class BookRide extends StatefulWidget {
  const BookRide({Key? key}) : super(key: key);

  @override
  State<BookRide> createState() => _BookRideState();
}

class _BookRideState extends State<BookRide> {
  late BookRideViewModel _viewModel;
  List<LatLng> _polyLinePoints = [];
  LatLng? _pickupLocation;
  LatLng? _dropoffLocation;
  LatLng? _driverLocation;

  @override
  void initState() {
    super.initState();
    _viewModel = BookRideViewModel(context);
    _fetchRideStatusAndLoadRoute();
  }

  Future<void> _fetchRideStatusAndLoadRoute() async {
    await _viewModel.fetchRideStatus();
    if (_viewModel.activeRideId != null) {
      _loadRoute();
      _setMarkerLocations();
      _listenToDriverLocation();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No ride request made yet.')),
      );
    }
  }

  Future<void> _loadRoute() async {
    final pickupLocation = _viewModel.pickupLocation;
    final dropoffLocation = _viewModel.dropoffLocation;

    final rideTemplateProvider =
        Provider.of<RideTemplateProvider>(context, listen: false);
    final selectedRideTemplate =
        rideTemplateProvider.getRideTemplate(pickupLocation!, dropoffLocation!);

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

  void _setMarkerLocations() {
    final pickupLocation = _viewModel.pickupLocation;
    final dropoffLocation = _viewModel.dropoffLocation;

    final rideTemplateProvider =
        Provider.of<RideTemplateProvider>(context, listen: false);
    final selectedRideTemplate =
        rideTemplateProvider.getRideTemplate(pickupLocation!, dropoffLocation!);

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

  void _listenToDriverLocation() {
    final driverId = _viewModel.driverdetail;

    FirebaseFirestore.instance
        .collection('driver location')
        .doc(driverId)
        .get()
        .then((snapshot) {
      if (snapshot.exists) {
        final data = snapshot.data();
        setState(() {
          _driverLocation = LatLng(data!['latitude'], data['longitude']);
        });
      }
    }).catchError((error) {
      print('Error fetching driver location: $error');
    });
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<BookRideViewModel>.value(
      value: _viewModel,
      child: Scaffold(
        body: Stack(
          children: [
            FlutterMap(
              options: const MapOptions(
                initialCenter: LatLng(1.558877361245217, 103.63759771629142),
                initialZoom: 15.0,
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
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
                if (_pickupLocation != null &&
                    _dropoffLocation != null &&
                    _driverLocation != null)
                  MarkerLayer(
                    key: UniqueKey(),
                    markers: [
                      Marker(
                        width: 20,
                        height: 20,
                        point: _driverLocation!,
                        child: const Icon(
                          Icons.drive_eta_rounded,
                          color: Colors.grey,
                          size: 40,
                        ),
                      ),
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
                  key: UniqueKey(),
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
            Padding(
              padding: const EdgeInsets.only(top: 16.0),
              child: Consumer<BookRideViewModel>(
                builder: (context, viewModel, child) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        FutureBuilder<bool>(
                          future: viewModel.hasActiveRide(),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const CircularProgressIndicator();
                            }
                            if (snapshot.hasData && snapshot.data == true) {
                              return Align(
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
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              viewModel.rideStatusMessage,
                                              style: const TextStyle(
                                                fontSize: 15,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            ElevatedButton(
                                              onPressed: () {
                                                if (viewModel
                                                        .rideStatusMessage ==
                                                    "Confirm Ride Completion") {
                                                  viewModel.showRatingDialog();
                                                  _pickupLocation = null;
                                                  _dropoffLocation = null;
                                                  _polyLinePoints =
                                                      List.empty();
                                                } else {
                                                  showDialog(
                                                    context: context,
                                                    builder:
                                                        (BuildContext context) {
                                                      return AlertDialog(
                                                        title: const Text(
                                                            'Cancel Ride'),
                                                        content: const Text(
                                                            'Are you sure you want to cancel the ride request?'),
                                                        actions: <Widget>[
                                                          TextButton(
                                                            onPressed: () {
                                                              Navigator.of(
                                                                      context)
                                                                  .pop();
                                                            },
                                                            child: const Text(
                                                                'No'),
                                                          ),
                                                          TextButton(
                                                            onPressed: () {
                                                              viewModel
                                                                  .cancelRide();
                                                              Navigator.of(
                                                                      context)
                                                                  .pop();
                                                            },
                                                            child: const Text(
                                                                'Yes'),
                                                          ),
                                                        ],
                                                      );
                                                    },
                                                  );
                                                }
                                              },
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor:
                                                    AppColors.uniMaroon,
                                              ),
                                              child: Text(
                                                viewModel.rideStatusMessage ==
                                                        "Confirm Ride Completion"
                                                    ? 'End Ride'
                                                    : 'Cancel Ride',
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
                              );
                            } else {
                              return Container();
                            }
                          },
                        ),
                        const Spacer(),
                        Container(
                          margin: const EdgeInsets.only(
                              bottom: 10.0, left: 10.0, right: 10.0),
                          child: Stack(
                            children: [
                              Align(
                                alignment: Alignment.bottomRight,
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    FloatingActionButton(
                                      heroTag: "detailsButton",
                                      onPressed: () {
                                        viewModel.showDetails(context);
                                      },
                                      backgroundColor: AppColors.uniMaroon,
                                      foregroundColor: AppColors.uniGold,
                                      child: const Icon(Icons.info),
                                    ),
                                    const SizedBox(height: 8),
                                    FloatingActionButton(
                                      heroTag: "bookingButton",
                                      onPressed: () async {
                                        bool hasActiveRide =
                                            await viewModel.hasActiveRide();
                                        if (hasActiveRide) {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            const SnackBar(
                                              content: Text(
                                                'You already have an active ride. Please complete it before booking a new one.',
                                              ),
                                            ),
                                          );
                                        } else {
                                          viewModel.showBookingForm(context);
                                        }
                                      },
                                      backgroundColor: AppColors.uniMaroon,
                                      foregroundColor: AppColors.uniGold,
                                      child: const Icon(Icons.directions_car),
                                    ),
                                    const SizedBox(height: 8),
                                    FloatingActionButton(
                                      heroTag: "refreshButton",
                                      onPressed: _fetchRideStatusAndLoadRoute,
                                      backgroundColor: AppColors.uniMaroon,
                                      foregroundColor: AppColors.uniGold,
                                      child: const Icon(Icons.refresh),
                                    ),
                                  ],
                                ),
                              ),
                              Positioned(
                                bottom: 2.0,
                                left: 2.0,
                                child: FloatingActionButton(
                                  onPressed: () async {
                                    bool hasActiveRide =
                                        await viewModel.hasActiveRide();
                                    if (hasActiveRide) {
                                      viewModel.routeReportDriver();
                                    } else if (viewModel.driverdetail == null) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                            'No driver Accepted the ride request',
                                          ),
                                        ),
                                      );
                                    } else {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                            'Cannot create report while there is no active ride',
                                          ),
                                        ),
                                      );
                                    }
                                  },
                                  backgroundColor: AppColors.uniMaroon,
                                  foregroundColor: AppColors.uniGold,
                                  child: const Icon(Icons.warning),
                                ),
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
