// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ManageUser extends StatefulWidget {
  const ManageUser({Key? key}) : super(key: key);

  @override
  State<ManageUser> createState() => _ManageUserState();
}

class _ManageUserState extends State<ManageUser> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Users'),
      ),
      body: Center(
        child: StreamBuilder<QuerySnapshot>(
          stream: _firestore.collection('users').snapshots(),
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
                DataColumn(label: Text('Actions')),
              ],
              rows: documents.map((document) {
                final Map<String, dynamic> data =
                    document.data() as Map<String, dynamic>;
                final String documentId = document.id;
                return DataRow(cells: [
                  DataCell(Text(data['email'] ?? '')),
                  DataCell(Text(data['password'] ?? '')),
                  DataCell(Text(data['fullname'] ?? '')),
                  DataCell(Text(data['MatricStaffNo'] ?? '')),
                  DataCell(Text(data['ICNO'] ?? '')),
                  DataCell(Text(data['telNo'] ?? '')),
                  DataCell(Text(data['collegeAddress'] ?? '')),
                  DataCell(
                    ElevatedButton(
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: const Text('Edit User'),
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
                                        hintText: data['fullname'] ?? '',
                                      ),
                                      onChanged: (value) {
                                        setState(() {
                                          data['fullname'] = value;
                                        });
                                      },
                                    ),
                                    TextField(
                                      decoration: InputDecoration(
                                        labelText: 'Matric/Staff Number',
                                        hintText: data['MatricStaffNo'] ?? '',
                                      ),
                                      onChanged: (value) {
                                        setState(() {
                                          data['MatricStaffNo'] = value;
                                        });
                                      },
                                    ),
                                    TextField(
                                      decoration: InputDecoration(
                                        labelText: 'IC Number',
                                        hintText: data['ICNO'] ?? '',
                                      ),
                                      onChanged: (value) {
                                        setState(() {
                                          data['ICNO'] = value;
                                        });
                                      },
                                    ),
                                    TextField(
                                      decoration: InputDecoration(
                                        labelText: 'Telephone Number',
                                        hintText: data['telNo'] ?? '',
                                      ),
                                      onChanged: (value) {
                                        setState(() {
                                          data['telNo'] = value;
                                        });
                                      },
                                    ),
                                    TextField(
                                      decoration: InputDecoration(
                                        labelText: 'College',
                                        hintText: data['collegeAddress'] ?? '',
                                      ),
                                      onChanged: (value) {
                                        setState(() {
                                          data['collegeAddress'] = value;
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
                                          .collection('users')
                                          .doc(documentId)
                                          .update(data);
                                      Navigator.of(context).pop();
                                    } catch (e) {
                                      print('Error updating user: $e');
                                    }
                                  },
                                  child: const Text('Save'),
                                ),
                                ElevatedButton(
                                  onPressed: () async {
                                    try {
                                      await FirebaseFirestore.instance
                                          .collection('users')
                                          .doc(documentId)
                                          .delete();
                                    } catch (e) {
                                      print('Error deleting user: $e');
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
