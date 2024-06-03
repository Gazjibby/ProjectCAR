import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:projectcar/Utils/colours.dart';

class CreateRideTemplate extends StatefulWidget {
  const CreateRideTemplate({super.key});

  @override
  State<CreateRideTemplate> createState() => _CreateRideTemplateState();
}

class _CreateRideTemplateState extends State<CreateRideTemplate> {
  TextEditingController _pickupNameController = TextEditingController();
  TextEditingController _dropoffNameController = TextEditingController();
  TextEditingController _priceController = TextEditingController();
  TextEditingController _pickupPoint = TextEditingController();
  TextEditingController _dropOffPoint = TextEditingController();

  LatLng? _pickupLocation;
  LatLng? _dropoffLocation;
  List<LatLng> _routePoints = [];

  void _addMarker(LatLng position) {
    if (_pickupLocation == null) {
      setState(() {
        _pickupLocation = position;
        _pickupPoint.text = '${position.latitude}, ${position.longitude}';
      });
    } else if (_dropoffLocation == null) {
      setState(() {
        _dropoffLocation = position;
        _dropOffPoint.text = '${position.latitude}, ${position.longitude}';
      });
      _fetchRoute();
    }
  }

  void _resetMarkers() {
    setState(() {
      _pickupLocation = null;
      _dropoffLocation = null;
      _pickupNameController.clear();
      _dropoffNameController.clear();
      _priceController.clear();
      _pickupPoint.clear();
      _dropOffPoint.clear();
      _routePoints.clear();
    });
  }

  Future<void> _fetchRoute() async {
    if (_pickupLocation != null && _dropoffLocation != null) {
      final url =
          'http://router.project-osrm.org/route/v1/driving/${_pickupLocation!.longitude},${_pickupLocation!.latitude};${_dropoffLocation!.longitude},${_dropoffLocation!.latitude}?overview=full&geometries=geojson';

      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        final route =
            jsonResponse['routes'][0]['geometry']['coordinates'] as List;
        setState(() {
          _routePoints = route
              .map((point) => LatLng(point[1] as double, point[0] as double))
              .toList();
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to fetch route')),
        );
      }
    }
  }

  void _saveRideTemplate() async {
    if (_pickupLocation != null &&
        _dropoffLocation != null &&
        _pickupNameController.text.isNotEmpty &&
        _dropoffNameController.text.isNotEmpty &&
        _priceController.text.isNotEmpty) {
      await FirebaseFirestore.instance.collection('Ride Template').add({
        'pickup': {
          'latitude': _pickupLocation!.latitude,
          'longitude': _pickupLocation!.longitude,
          'pickupPointName': _pickupNameController.text,
        },
        'dropoff': {
          'latitude': _dropoffLocation!.latitude,
          'longitude': _dropoffLocation!.longitude,
          'dropOffPointName': _dropoffNameController.text,
        },
        'price': double.parse(_priceController.text),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ride template saved successfully')),
      );

      _resetMarkers();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text(
                'Please select both pickup and dropoff locations and enter names and price')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Ride Template'),
      ),
      body: Stack(
        children: [
          FlutterMap(
            options: MapOptions(
              initialCenter:
                  const LatLng(1.558877361245217, 103.63759771629142),
              initialZoom: 15.0,
              onTap: (tapPosition, point) {
                _addMarker(point);
              },
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.app',
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
                    points: _routePoints,
                    color: Colors.blue,
                    strokeWidth: 4.0,
                  ),
                ],
              ),
            ],
          ),
          Align(
            alignment: Alignment.bottomRight,
            child: FractionallySizedBox(
              widthFactor: 0.3,
              heightFactor: 0.45,
              child: Card(
                color: AppColors.uniPeach,
                elevation: 8,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(5),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'Create Ride Template',
                        style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white),
                      ),
                      TextField(
                        controller: _pickupNameController,
                        decoration:
                            const InputDecoration(labelText: 'Pickup Name'),
                      ),
                      TextField(
                        controller: _pickupPoint,
                        decoration:
                            const InputDecoration(labelText: 'Pickup Point'),
                        readOnly: true,
                      ),
                      TextField(
                        controller: _dropoffNameController,
                        decoration:
                            const InputDecoration(labelText: 'Dropoff Name'),
                      ),
                      TextField(
                        controller: _dropOffPoint,
                        decoration:
                            const InputDecoration(labelText: 'Dropoff Point'),
                        readOnly: true,
                      ),
                      TextField(
                        controller: _priceController,
                        decoration: const InputDecoration(labelText: 'Price'),
                        keyboardType: TextInputType.number,
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          ElevatedButton(
                            onPressed: _resetMarkers,
                            child: const Text('Clear'),
                          ),
                          ElevatedButton(
                            onPressed: _saveRideTemplate,
                            child: const Text('Save'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
