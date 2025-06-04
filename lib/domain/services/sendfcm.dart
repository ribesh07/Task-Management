import 'dart:convert';

import 'package:http/http.dart' as http;

Future<void> sendFCM({
  required String title,
  required String body,
  required String toToken, // Receiver's token
}) async {
  const String serverKey =
      'YOUR_FIREBASE_SERVER_KEY'; // get from Firebase console

  final response = await http.post(
    Uri.parse('https://fcm.googleapis.com/fcm/send'),
    headers: {
      'Content-Type': 'application/json',
      'Authorization': 'key=$serverKey',
    },
    body: jsonEncode({
      "to": toToken,
      "notification": {
        "title": title,
        "body": body,
      }
    }),
  );

  if (response.statusCode == 200) {
    print("✅ Notification sent");
  } else {
    print("❌ Failed to send: ${response.body}");
  }
}


// await ref.read(taskDatasourceProvider).updateTaskStatus(task.id, newStatus);
// await sendFCM(
//   title: 'Task Status Updated',
//   body: 'Task "${task.title}" moved to $newStatus',
//   toToken: receiverToken, // get from Firestore
// );


// await ref.read(taskDatasourceProvider).updateTaskDescription(task.id, newDesc);
// await sendFCM(
//   title: 'Task Edited',
//   body: 'Task "${task.title}" description updated',
//   toToken: receiverToken,
// );


// await ref.read(taskDatasourceProvider).deleteTask(task.id);
// await sendFCM(
//   title: 'Task Deleted',
//   body: 'Task "${task.title}" was deleted',
//   toToken: receiverToken,
// );

// final snap = await FirebaseFirestore.instance.collection('user_tokens').get();
// for (var doc in snap.docs) {
//   final token = doc['token'];
//   await sendFCM(title: ..., body: ..., toToken: token);
// }
