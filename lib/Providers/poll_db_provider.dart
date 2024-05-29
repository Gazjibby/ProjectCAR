import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

class PollDbProvider extends ChangeNotifier {
  String _message = "";

  bool _status = false;
  bool _deleteStatus = false;

  String get message => _message;
  bool get status => _status;
  bool get deleteStatus => _deleteStatus;

  CollectionReference pollCollection =
      FirebaseFirestore.instance.collection("Voting Session");

  void addPoll(
      {required String question,
      required String reason,
      required DateTime endDate,
      required List<Map> options}) async {
    _status = true;
    notifyListeners();
    try {
      final data = {
        "author": "SuperAdmin",
        "dateCreated": DateTime.now(),
        "poll": {
          "total_votes": 0,
          "voters": <Map>[],
          "question": question,
          "reasoning": reason,
          "endDate": endDate,
          "options": options,
        }
      };

      await pollCollection.add(data);
      _message = "Poll Created";
      _status = false;
      notifyListeners();
    } on FirebaseException catch (e) {
      _message = e.message!;
      _status = false;
      notifyListeners();
    } catch (e) {
      _message = "Please try again...";
      _status = false;
      notifyListeners();
    }
  }

  void votePoll(
      {required String? pollId,
      required DocumentSnapshot pollData,
      required int previousTotalVotes,
      required String driverMatricStaffNumber,
      required String seletedOptions}) async {
    _status = true;
    notifyListeners();

    try {
      List voters = pollData['poll']["voters"];

      voters.add({
        "driverMatricStaffNumber": driverMatricStaffNumber,
        "selected_option": seletedOptions,
      });

      List options = pollData["poll"]["options"];
      for (var i in options) {
        if (i["answer"] == seletedOptions) {
          i["percent"]++;
        } else {
          if (i["percent"] > 0) {
            i["percent"]--;
          }
        }
      }

      final data = {
        "author": pollData["author"],
        "dateCreated": pollData["dateCreated"],
        "poll": {
          "total_votes": previousTotalVotes + 1,
          "voters": voters,
          "question": pollData["poll"]["question"],
          "endDate": pollData["poll"]["endDate"],
          "options": options,
        }
      };

      await pollCollection.doc(pollId).update(data);
      _message = "Vote Recorded";
      _status = false;
      notifyListeners();
    } on FirebaseException catch (e) {
      _message = e.message!;
      _status = false;
      notifyListeners();
    } catch (e) {
      _message = "Please try again...";
      _status = false;
      notifyListeners();
    }
  }

  void endPoll({required String pollId}) async {
    _deleteStatus = true;
    notifyListeners();

    try {
      Timestamp currentTimestamp = Timestamp.fromDate(DateTime.now());

      await pollCollection.doc(pollId).update({
        "poll.endDate": currentTimestamp,
      });

      QuerySnapshot driversSnapshot =
          await FirebaseFirestore.instance.collection('drivers').get();

      WriteBatch batch = FirebaseFirestore.instance.batch();
      for (var doc in driversSnapshot.docs) {
        batch.update(doc.reference, {"voteFlag": "0"});
      }
      await batch.commit();

      _message = "Poll Ended and driver voteFlags updated";
      _deleteStatus = false;
      notifyListeners();
    } on FirebaseException catch (e) {
      _message = e.message!;
      _deleteStatus = false;
      notifyListeners();
    } catch (e) {
      _message = "Please try again...";
      _deleteStatus = false;
      notifyListeners();
    }
  }

  void clear() {
    _message = "";
    notifyListeners();
  }
}
