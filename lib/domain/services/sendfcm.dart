import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:googleapis_auth/auth_io.dart';
// import 'package:http/http.dart' as http;
import 'dart:convert';

Future<List<String>> getAllDeviceTokens() async {
  try {
    final snapshot =
        await FirebaseFirestore.instance.collection('tokens').get();
    return snapshot.docs.map((doc) => doc['token'] as String).toList();
  } catch (e) {
    print('Error reading tokens: $e');
    return [];
  }
}

Future<void> sendFCMToAllTokens({
  required String title,
  required String body,
}) async {
  final tokens = await getAllDeviceTokens();
  print('Sending FCM to ${tokens.length} tokens');
  if (tokens.isEmpty) {
    print('No device tokens found.');
    return;
  }
  final serviceAccountJson =
      await rootBundle.loadString('assets/services.json');
  final serviceAccount = jsonDecode(serviceAccountJson);
  final projectId = serviceAccount['project_id'] as String;

  final client = await clientViaServiceAccount(
    ServiceAccountCredentials.fromJson(serviceAccount),
    ['https://www.googleapis.com/auth/firebase.messaging'],
  );

  for (final token in tokens) {
    final response = await client.post(
      Uri.parse(
          'https://fcm.googleapis.com/v1/projects/$projectId/messages:send'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'message': {
          'token': token,
          'notification': {
            'title': title,
            'body': body,
          },
        },
      }),
    );

    if (response.statusCode != 200) {
      print('Error sending notification to $token: ${response.statusCode}');
      print('Failed to send notification to $token: ${response.body}');
    } else {
      print('Notification sent to $token');
    }
  }

  client.close();
}
