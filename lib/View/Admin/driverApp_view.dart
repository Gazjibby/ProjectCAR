import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:projectcar/View/Admin/application_card.dart';
import 'package:url_launcher/url_launcher.dart';

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

            // return DataTable(
            //   columns: const [
            //     DataColumn(label: Text('Email')),
            //     DataColumn(label: Text('Full Name')),
            //     DataColumn(label: Text('Matric/Staff Number')),
            //     DataColumn(label: Text('IC Number')),
            //     DataColumn(label: Text('Telephone Number')),
            //     DataColumn(label: Text('College')),
            //     DataColumn(label: Text('Photo')),
            //     DataColumn(label: Text('Actions')),
            //   ],
            //   rows: documents.map((document) {
            //     final Map<String, dynamic> data =
            //         document.data() as Map<String, dynamic>;
            //     final String documentId = document.id;
            //     return DataRow(cells: [
            //       DataCell(Text(data['email'] ?? '')),
            //       DataCell(Text(data['fullName'] ?? '')),
            //       DataCell(Text(data['matricStaffNumber'] ?? '')),
            //       DataCell(Text(data['icNumber'] ?? '')),
            //       DataCell(Text(data['telephoneNumber'] ?? '')),
            //       DataCell(Text(data['college'] ?? '')),
            //       DataCell(
            //         GestureDetector(
            //           onTap: () {
            //             launchUrl(Uri.parse(data['photoUrl'] ?? ''));
            //           },
            //           child: const Icon(Icons.photo, size: 24),
            //         ),
            //       ),
            //       DataCell(
            //         Row(
            //           children: [
            //             ElevatedButton(
            //               onPressed: () async {
            //                 await _firestore
            //                     .collection('drivers')
            //                     .doc(documentId)
            //                     .update({'status': 'Active'});
            //               },
            //               child: const Text('Accept'),
            //             ),
            //             ElevatedButton(
            //               onPressed: () async {
            //                 await _firestore
            //                     .collection('drivers')
            //                     .doc(documentId)
            //                     .update({'status': 'Rejected'});
            //               },
            //               child: const Text('Reject'),
            //             ),
            //           ],
            //         ),
            //       ),
            //     ]);
            //   }).toList(),
            // );

            // return ApplicationCard(email: email, fullName: fullName, matricStaffNumber: matricStaffNumber, icNumber: icNumber, telephoneNumber: telephoneNumber, college: college, photoUrl: photoUrl, documentId: documentId)

            return ListView.builder(
              padding: const EdgeInsets.all(8),
              itemCount: documents.length,
              itemBuilder: (context, index) {
                final Map<String, dynamic> data =
                    documents[index].data() as Map<String, dynamic>;
                final String documentId = documents[index].id;
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
