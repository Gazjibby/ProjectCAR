import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class FetchPollsProvider extends ChangeNotifier {
  List<DocumentSnapshot> _pollsList = [];

  bool _isLoading = true;

  bool get isLoading => _isLoading;

  List<DocumentSnapshot> get pollsList => _pollsList;

  CollectionReference pollCollection =
      FirebaseFirestore.instance.collection("Voting Session");

  void fetchPolls() async {
    Query pollQuery =
        pollCollection.where("poll.endDate", isGreaterThan: DateTime.now());

    pollQuery.get().then((QuerySnapshot value) {
      if (value.docs.isEmpty) {
        _pollsList.clear();
        _isLoading = false;
        notifyListeners();
      } else {
        final data = value.docs;

        _pollsList = data;
        _isLoading = false;
        notifyListeners();
      }
    });
  }
}
