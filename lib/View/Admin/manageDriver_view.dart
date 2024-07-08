import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:projectcar/View/AccReg/driver_reg_view.dart';
import 'package:projectcar/ViewModel/manage_driver_viewmodel.dart';
import 'package:provider/provider.dart';

class ManageDriver extends StatefulWidget {
  const ManageDriver({super.key});

  @override
  State<ManageDriver> createState() => _ManageDriverState();
}

class _ManageDriverState extends State<ManageDriver> {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ManageDriverViewModel(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Manage Active Drivers'),
        ),
        body: Stack(
          children: [
            Center(
              child: Consumer<ManageDriverViewModel>(
                builder: (context, viewModel, child) {
                  return StreamBuilder<QuerySnapshot>(
                    stream: viewModel.getActiveDriversStream(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return const CircularProgressIndicator();
                      }

                      final List<DocumentSnapshot> documents =
                          snapshot.data!.docs;

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
                                  final photoUrl =
                                      data['Car Details']['photoUrl'] ?? '';
                                  if (photoUrl.isNotEmpty) {
                                    final uri = Uri.parse(photoUrl);
                                    viewModel.launchPhotoUrl(uri);
                                  } else {}
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
                                                  hintText:
                                                      data['password'] ?? '',
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
                                                  hintText:
                                                      data['fullName'] ?? '',
                                                ),
                                                onChanged: (value) {
                                                  setState(() {
                                                    data['fullName'] = value;
                                                  });
                                                },
                                              ),
                                              TextField(
                                                decoration: InputDecoration(
                                                  labelText:
                                                      'Matric/Staff Number',
                                                  hintText: data[
                                                          'matricStaffNumber'] ??
                                                      '',
                                                ),
                                                onChanged: (value) {
                                                  setState(() {
                                                    data['matricStaffNumber'] =
                                                        value;
                                                  });
                                                },
                                              ),
                                              TextField(
                                                decoration: InputDecoration(
                                                  labelText: 'IC Number',
                                                  hintText:
                                                      data['icNumber'] ?? '',
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
                                                  hintText:
                                                      data['telephoneNumber'] ??
                                                          '',
                                                ),
                                                onChanged: (value) {
                                                  setState(() {
                                                    data['telephoneNumber'] =
                                                        value;
                                                  });
                                                },
                                              ),
                                              TextField(
                                                decoration: InputDecoration(
                                                  labelText: 'College',
                                                  hintText:
                                                      data['college'] ?? '',
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
                                              await viewModel.updateDriver(
                                                  documentId, data);
                                              Navigator.of(context).pop();
                                            },
                                            child: const Text('Save'),
                                          ),
                                          ElevatedButton(
                                            onPressed: () async {
                                              await viewModel
                                                  .deleteDriver(documentId);
                                              Navigator.of(context).pop();
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
                  );
                },
              ),
            ),
            Align(
              alignment: Alignment.bottomRight,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => DriverRegView()),
                    );
                  },
                  child: const Text('Insert Driver'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
