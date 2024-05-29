// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';

class ManageDriver extends StatefulWidget {
  const ManageDriver({super.key});

  @override
  State<ManageDriver> createState() => _ManageDriverState();
}

class _ManageDriverState extends State<ManageDriver> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Active Drivers'),
      ),
      body: Center(
        child: StreamBuilder<QuerySnapshot>(
          stream: _firestore
              .collection('drivers')
              .where('status', isEqualTo: 'Active')
              .snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const CircularProgressIndicator();
            }

            final List<DocumentSnapshot> documents = snapshot.data!.docs;

            return DataTable(
              columns: const [
                DataColumn(label: Text('Email')),
                DataColumn(label: Text('Password')),
                DataColumn(label: Text('Full Name')),
                DataColumn(label: Text('Matric/Staff Number')),
                DataColumn(label: Text('IC Number')),
                DataColumn(label: Text('Telephone Number')),
                DataColumn(label: Text('College')),
                DataColumn(label: Text('Vote Flag')),
                DataColumn(label: Text('Vehicle Photo')),
                DataColumn(label: Text('Actions')),
              ],
              rows: documents.map((document) {
                final Map<String, dynamic> data =
                    document.data() as Map<String, dynamic>;
                final String documentId = document.id;
                return DataRow(cells: [
                  DataCell(Text(data['email'] ?? '')),
                  DataCell(Text(data['password'] ?? '')),
                  DataCell(Text(data['fullName'] ?? '')),
                  DataCell(Text(data['matricStaffNumber'] ?? '')),
                  DataCell(Text(data['icNumber'] ?? '')),
                  DataCell(Text(data['telephoneNumber'] ?? '')),
                  DataCell(Text(data['college'] ?? '')),
                  DataCell(Text(data['voteFlag'] ?? '')),
                  DataCell(
                    GestureDetector(
                      onTap: () {
                        launchUrl(Uri.parse(data['photoUrl'] ?? ''));
                      },
                      child: const Icon(Icons.photo, size: 24),
                    ),
                  ),
                  DataCell(
                    ElevatedButton(
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: const Text('Edit Driver'),
                              content: SingleChildScrollView(
                                child: Column(
                                  children: [
                                    TextField(
                                      decoration: InputDecoration(
                                        labelText: 'Email',
                                        hintText: data['email'] ?? '',
                                      ),
                                      onChanged: (value) {
                                        setState(() {
                                          data['email'] = value;
                                        });
                                      },
                                    ),
                                    TextField(
                                      decoration: InputDecoration(
                                        labelText: 'Password',
                                        hintText: data['password'] ?? '',
                                      ),
                                      onChanged: (value) {
                                        setState(() {
                                          data['password'] = value;
                                        });
                                      },
                                    ),
                                    TextField(
                                      decoration: InputDecoration(
                                        labelText: 'Full Name',
                                        hintText: data['fullName'] ?? '',
                                      ),
                                      onChanged: (value) {
                                        setState(() {
                                          data['fullName'] = value;
                                        });
                                      },
                                    ),
                                    TextField(
                                      decoration: InputDecoration(
                                        labelText: 'Matric/Staff Number',
                                        hintText:
                                            data['matricStaffNumber'] ?? '',
                                      ),
                                      onChanged: (value) {
                                        setState(() {
                                          data['matricStaffNumber'] = value;
                                        });
                                      },
                                    ),
                                    TextField(
                                      decoration: InputDecoration(
                                        labelText: 'IC Number',
                                        hintText: data['icNumber'] ?? '',
                                      ),
                                      onChanged: (value) {
                                        setState(() {
                                          data['icNumber'] = value;
                                        });
                                      },
                                    ),
                                    TextField(
                                      decoration: InputDecoration(
                                        labelText: 'Telephone Number',
                                        hintText: data['telephoneNumber'] ?? '',
                                      ),
                                      onChanged: (value) {
                                        setState(() {
                                          data['telephoneNumber'] = value;
                                        });
                                      },
                                    ),
                                    TextField(
                                      decoration: InputDecoration(
                                        labelText: 'College',
                                        hintText: data['college'] ?? '',
                                      ),
                                      onChanged: (value) {
                                        setState(() {
                                          data['college'] = value;
                                        });
                                      },
                                    ),
                                  ],
                                ),
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                  child: const Text('Cancel'),
                                ),
                                ElevatedButton(
                                  onPressed: () async {
                                    try {
                                      await FirebaseFirestore.instance
                                          .collection('drivers')
                                          .doc(documentId)
                                          .update(data);
                                      Navigator.of(context).pop();
                                    } catch (e) {
                                      print('Error updating driver: $e');
                                    }
                                  },
                                  child: const Text('Save'),
                                ),
                                ElevatedButton(
                                  onPressed: () async {
                                    try {
                                      await FirebaseFirestore.instance
                                          .collection('drivers')
                                          .doc(documentId)
                                          .delete();
                                    } catch (e) {
                                      print('Error deleting driver: $e');
                                    }
                                  },
                                  child: const Text('Remove'),
                                ),
                              ],
                            );
                          },
                        );
                      },
                      child: const Text('Edit'),
                    ),
                  ),
                ]);
              }).toList(),
            );
          },
        ),
      ),
    );
  }
}
