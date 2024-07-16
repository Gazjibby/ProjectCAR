import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:projectcar/Model/report.dart';

class ReportViewModel with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> submitReport(ReportModel report) async {
    try {
      await _firestore.collection('Reports').add(report.toMap());
    } catch (e) {
      print('Error submitting report: $e');
    }
  }
}
