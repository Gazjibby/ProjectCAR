import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:projectcar/View/Admin/driver_app_viewmodel.dart';

class DriverApplication extends StatefulWidget {
  const DriverApplication({super.key});

  @override
  State<DriverApplication> createState() => _DriverApplicationState();
}

class _DriverApplicationState extends State<DriverApplication> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Driver Applications'),
      ),
      body: Center(
        child: StreamBuilder<QuerySnapshot>(
          stream: _firestore
              .collection('drivers')
              .where('status', isEqualTo: 'pending')
              .snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const CircularProgressIndicator();
            }

            final List<DocumentSnapshot> documents = snapshot.data!.docs;

            return ListView.builder(
              padding: const EdgeInsets.all(8),
              itemCount: documents.length,
              itemBuilder: (context, index) {
                final Map<String, dynamic> data =
                    documents[index].data() as Map<String, dynamic>;
                return ApplicationCard(
                  email: data['email'] ?? '',
                  fullName: data['fullName'] ?? '',
                  matricStaffNumber: data['matricStaffNumber'] ?? '',
                  icNumber: data['icNumber'] ?? '',
                  telephoneNumber: data['telephoneNumber'] ?? '',
                  college: data['college'] ?? '',
                  photoUrl: data['Car Details'] != null
                      ? data['Car Details']['photoUrl'] ?? ''
                      : '',
                );
              },
            );
          },
        ),
      ),
    );
  }
}
