import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CreateRideTemplate extends StatefulWidget {
  const CreateRideTemplate({super.key});

  @override
  State<CreateRideTemplate> createState() => _CreateRideTemplateState();
}

class _CreateRideTemplateState extends State<CreateRideTemplate> {
  TextEditingController _pickupNameController = TextEditingController();
  TextEditingController _dropoffNameController = TextEditingController();
  TextEditingController _priceController = TextEditingController();

  LatLng? _pickupLocation;
  LatLng? _dropoffLocation;

  void _addMarker(LatLng position) {
    if (_pickupLocation == null) {
      setState(() {
        _pickupLocation = position;
      });
    } else if (_dropoffLocation == null) {
      setState(() {
        _dropoffLocation = position;
      });
    }
  }

  void _resetMarkers() {
    setState(() {
      _pickupLocation = null;
      _dropoffLocation = null;
      _pickupNameController.clear();
      _dropoffNameController.clear();
      _priceController.clear();
    });
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

  void _showLocationDialog() {
    if (_pickupLocation != null && _dropoffLocation != null) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Selected Locations'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _pickupNameController,
                decoration: const InputDecoration(labelText: 'Pickup Name'),
              ),
              TextField(
                controller: _dropoffNameController,
                decoration: const InputDecoration(labelText: 'Dropoff Name'),
              ),
              TextField(
                controller: _priceController,
                decoration: const InputDecoration(labelText: 'Price'),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _saveRideTemplate();
              },
              child: const Text('Save'),
            ),
          ],
        ),
      );
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
            ],
          ),
        ],
      ),
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            onPressed: _showLocationDialog,
            child: const Icon(Icons.save),
          ),
          const SizedBox(width: 16),
          FloatingActionButton(
            onPressed: _resetMarkers,
            child: const Icon(Icons.clear),
          ),
        ],
      ),
    );
  }
}
