import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:googleapis_auth/auth_io.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_core/firebase_core.dart';

class NotificationService {
  static const String _serviceAccountPath =
      'lib/Asset/utmcar-62352-6b969942405a.json';
  static const String _projectID = 'utmcar-62352';

  Future<void> initFirebase() async {
    await Firebase.initializeApp();
  }

  Future<String> _getAccessToken() async {
    final serviceAccountJson = json.decode(
      await rootBundle.loadString(_serviceAccountPath),
    );

    final accountCredentials =
        ServiceAccountCredentials.fromJson(serviceAccountJson);

    final authClient = await clientViaServiceAccount(
      accountCredentials,
      ['https://www.googleapis.com/auth/firebase.messaging'],
    );

    return authClient.credentials.accessToken.data;
  }

  Future<void> sendNotification(String token, String title, String body) async {
    try {
      final String accessToken = await _getAccessToken();

      final Uri url = Uri.parse(
          'https://fcm.googleapis.com/v1/projects/$_projectID/messages:send');

      final response = await http.post(
        url,
        headers: <String, String>{
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
        body: jsonEncode(<String, dynamic>{
          'message': {
            'token': token,
            'notification': {
              'title': title,
              'body': body,
            },
          },
        }),
      );

      if (response.statusCode == 200) {
        print('Notification sent successfully');
      } else {
        print('Failed to send notification: ${response.statusCode}');
        print('Response body: ${response.body}');
      }
    } catch (e) {
      print('Error sending notification: $e');
    }
  }
}
