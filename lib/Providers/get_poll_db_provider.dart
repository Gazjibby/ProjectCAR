import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class FetchPollsProvider extends ChangeNotifier {
  List<DocumentSnapshot> _pollsList = [];
  List<DocumentSnapshot> _allPollsList = [];

  bool _isLoading = true;

  bool get isLoading => _isLoading;

  List<DocumentSnapshot> get pollsList => _pollsList;
  List<DocumentSnapshot> get allPollsList => _allPollsList;

  CollectionReference pollCollection =
      FirebaseFirestore.instance.collection("Voting Session");

  void fetchPolls() async {
    _isLoading = true;
    notifyListeners();

    Query pollQuery =
        pollCollection.where("poll.endDate", isGreaterThan: DateTime.now());

    try {
      QuerySnapshot value = await pollQuery.get();

      if (value.docs.isEmpty) {
        _pollsList.clear();
      } else {
        _pollsList = value.docs.toList();
      }
    } catch (e) {
      print("Error fetching active polls: $e");
      _pollsList.clear();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void fetchAllPolls() async {
    _isLoading = true;
    notifyListeners();

    try {
      QuerySnapshot value = await pollCollection.get();

      if (value.docs.isEmpty) {
        _allPollsList.clear();
      } else {
        _allPollsList = value.docs.toList();
      }
    } catch (e) {
      print("Error fetching all polls: $e");
      _allPollsList.clear();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
