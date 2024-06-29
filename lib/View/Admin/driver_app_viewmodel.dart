import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ApplicationCard extends StatefulWidget {
  final String email;
  final String fullName;
  final String matricStaffNumber;
  final String icNumber;
  final String telephoneNumber;
  final String college;
  final String photoUrl;

  const ApplicationCard({
    super.key,
    required this.email,
    required this.fullName,
    required this.matricStaffNumber,
    required this.icNumber,
    required this.telephoneNumber,
    required this.college,
    required this.photoUrl,
  });

  @override
  State<ApplicationCard> createState() => _ApplicationCardState();
}

class _ApplicationCardState extends State<ApplicationCard> {
  Future<void> _acceptApplication() async {
    try {
      final driverDoc = await FirebaseFirestore.instance
          .collection('drivers')
          .where('matricStaffNumber', isEqualTo: widget.matricStaffNumber)
          .limit(1)
          .get();

      if (driverDoc.docs.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Driver not found')),
        );
        return;
      }

      final driverId = driverDoc.docs.first.id;

      await FirebaseFirestore.instance
          .collection('drivers')
          .doc(driverId)
          .update({'status': 'Active'});

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Application accepted')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  Future<void> _rejectApplication() async {
    try {
      final driverDoc = await FirebaseFirestore.instance
          .collection('drivers')
          .where('matricStaffNumber', isEqualTo: widget.matricStaffNumber)
          .limit(1)
          .get();

      if (driverDoc.docs.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Driver not found')),
        );
        return;
      }

      final driverId = driverDoc.docs.first.id;

      await FirebaseFirestore.instance
          .collection('drivers')
          .doc(driverId)
          .update({'status': 'Rejected'});

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Application rejected')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 120.0,
            vertical: 8.0,
          ),
          child: Card(
            child: SizedBox(
              width: 500,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    CachedNetworkImage(
                      imageUrl: widget.photoUrl,
                      width: 500,
                      height: 200,
                      placeholder: (context, url) {
                        return const Center(
                          child: CircularProgressIndicator(),
                        );
                      },
                      errorWidget: (context, url, error) {
                        return Center(
                          child: SelectableText('Error loading image: $error'),
                        );
                      },
                    ),
                    DataListTile(title: 'Name', data: widget.fullName),
                    DataListTile(title: 'Email', data: widget.email),
                    DataListTile(
                        title: 'Matric/Staff Number',
                        data: widget.matricStaffNumber),
                    DataListTile(title: 'IC Number', data: widget.icNumber),
                    DataListTile(
                        title: 'Telephone Number',
                        data: widget.telephoneNumber),
                    DataListTile(title: 'College', data: widget.college),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton(
                          onPressed: _acceptApplication,
                          child: const Text('Accept'),
                        ),
                        ElevatedButton(
                          onPressed: _rejectApplication,
                          child: const Text('Reject'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class DataListTile extends StatelessWidget {
  final String title;
  final String data;

  const DataListTile({
    super.key,
    required this.title,
    required this.data,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      subtitle: Text(data),
    );
  }
}
