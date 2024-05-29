import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:projectcar/Model/ride_template.dart';

class RideTemplateProvider with ChangeNotifier {
  List<RideTemplate> _rideTemplates = [];

  List<RideTemplate> get rideTemplates => _rideTemplates;

  RideTemplateProvider() {
    fetchRideTemplates();
  }

  Future<void> fetchRideTemplates() async {
    final snapshot =
        await FirebaseFirestore.instance.collection('Ride Template').get();
    _rideTemplates =
        snapshot.docs.map((doc) => RideTemplate.fromMap(doc.data())).toList();
    notifyListeners();
  }

  RideTemplate? getRideTemplate(String pickup, String dropoff) {
    return _rideTemplates.firstWhere(
      (template) => template.pickup == pickup && template.dropoff == dropoff,
    );
  }
}
