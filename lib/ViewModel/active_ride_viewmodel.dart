import 'package:flutter/material.dart';
import 'package:projectcar/Model/active_ride.dart';
import 'package:projectcar/Providers/active_ride_provider.dart';
import 'package:projectcar/Providers/ride_template_provider.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ActiveRideViewModel extends ChangeNotifier {
  final ActiveRideProvider _activeRideProvider;
  final RideTemplateProvider _rideTemplateProvider;
  ActiveRideModel? _activeRide;
  List<LatLng> _polyLinePoints = [];
  LatLng? _pickupLocation;
  LatLng? _dropoffLocation;

  ActiveRideViewModel(this._activeRideProvider, this._rideTemplateProvider);

  ActiveRideModel? get activeRide => _activeRide;
  List<LatLng> get polyLinePoints => _polyLinePoints;
  LatLng? get pickupLocation => _pickupLocation;
  LatLng? get dropoffLocation => _dropoffLocation;

  Future<void> fetchActiveRide(String matricStaffNumber) async {
    await _activeRideProvider.fetchActiveRide(matricStaffNumber);
    _activeRide = _activeRideProvider.activeRide;
    if (_activeRide != null) {
      await _loadRoute(
          _activeRide!.dropoffLocation, _activeRide!.pickupLocation);
      await _setMarkerLocations(
          _activeRide!.dropoffLocation, _activeRide!.pickupLocation);
    }
    notifyListeners();
  }

  Future<void> _loadRoute(String dropOffLocation, String pickUpLocation) async {
    final pickupLocation = pickUpLocation;
    final dropoffLocation = dropOffLocation;

    final selectedRideTemplate =
        _rideTemplateProvider.getRideTemplate(pickupLocation, dropoffLocation);

    final pickupLatitude = selectedRideTemplate?.pickupLat;
    final pickupLongitude = selectedRideTemplate?.pickupLng;
    final dropoffLatitude = selectedRideTemplate?.dropoffLat;
    final dropoffLongitude = selectedRideTemplate?.dropoffLng;

    if (pickupLatitude == null ||
        pickupLongitude == null ||
        dropoffLatitude == null ||
        dropoffLongitude == null) {
      throw Exception('Failed to load ride template locations');
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
          _polyLinePoints = routePoints
              .map((point) => LatLng(point[1] as double, point[0] as double))
              .toList();
        } else {
          throw Exception('Route points not found');
        }
      } else {
        throw Exception('Routes not found');
      }
    } else {
      throw Exception('Failed to fetch route');
    }
    notifyListeners();
  }

  Future<void> _setMarkerLocations(
      String dropOffLocation, String pickUpLocation) async {
    final pickupLocation = pickUpLocation;
    final dropoffLocation = dropOffLocation;

    final selectedRideTemplate =
        _rideTemplateProvider.getRideTemplate(pickupLocation, dropoffLocation);

    if (selectedRideTemplate != null) {
      final pickupLatitude = selectedRideTemplate.pickupLat;
      final pickupLongitude = selectedRideTemplate.pickupLng;
      final dropoffLatitude = selectedRideTemplate.dropoffLat;
      final dropoffLongitude = selectedRideTemplate.dropoffLng;

      double convertpickupLatitude = pickupLatitude.clamp(-90.0, 90.0);
      double convertpickupLongitude = pickupLongitude.clamp(-180.0, 180.0);
      double convertdropoffLatitude = dropoffLatitude.clamp(-90.0, 90.0);
      double convertdropoffLongitude = dropoffLongitude.clamp(-180.0, 180.0);

      _pickupLocation = LatLng(convertpickupLatitude, convertpickupLongitude);
      _dropoffLocation =
          LatLng(convertdropoffLatitude, convertdropoffLongitude);
    }
    notifyListeners();
  }

  void showQrCodeDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('QR Code'),
          content: Image.asset(
            'lib/Asset/images/DummyQR.png',
            width: 200.0,
            height: 200.0,
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
}
