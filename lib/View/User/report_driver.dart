import 'package:flutter/material.dart';
import 'package:projectcar/Model/report.dart';
import 'package:projectcar/ViewModel/report_viewmodel.dart';
import 'package:provider/provider.dart';

class ReportDriver extends StatelessWidget {
  final String driverAccepted;
  final String userRequest;
  final String rideID;

  ReportDriver({
    super.key,
    required this.driverAccepted,
    required this.userRequest,
    required this.rideID,
  });

  final _formKey = GlobalKey<FormState>();
  final TextEditingController _descriptionController = TextEditingController();
  String _reportType = 'Please Select';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Report Driver')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              DropdownButtonFormField<String>(
                value: _reportType,
                items: <String>[
                  'Please Select',
                  'Inappropriate Behavior',
                  'Late Arrival',
                  'Incorrect Route',
                  'Other',
                ].map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  _reportType = newValue!;
                },
                decoration: const InputDecoration(labelText: 'Report Type'),
                validator: (value) {
                  if (value == 'Please Select') {
                    return 'Please select a report type';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Description'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a description';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    final report = ReportModel(
                      reportAuthor: 'User',
                      reportType: _reportType,
                      description: _descriptionController.text,
                      rideID: rideID,
                      driverAccepted: driverAccepted,
                      userRequest: userRequest,
                      timestamp: DateTime.now(),
                    );

                    await Provider.of<ReportViewModel>(context, listen: false)
                        .submitReport(report);

                    Navigator.of(context).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Report submitted')),
                    );
                  }
                },
                child: const Text('Submit Report'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
