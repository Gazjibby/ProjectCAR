import 'package:location/location.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class LocationService {
  final String matricStaffNumber;

  final Location _location = Location();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  LocationService(this.matricStaffNumber) {
    String driverMatricStaffNumber = matricStaffNumber;
    _location.changeSettings(interval: 120000);
    _location.onLocationChanged.listen((LocationData currentLocation) {
      _updateLocation(currentLocation, driverMatricStaffNumber);
    });
  }

  Future<LocationData> getCurrentLocation() async {
    return await _location.getLocation();
  }

  Future<void> _updateLocation(
      LocationData locationData, String driverMatricStaffNumber) async {
    final driverId = driverMatricStaffNumber;

    await _firestore.collection('driver location').doc(driverId).set({
      'latitude': locationData.latitude,
      'longitude': locationData.longitude,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }
}
