import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

final fcmTokenProvider = StateProvider<String?>((ref) => null);

final fcmTokenInitializerProvider = Provider<void>((ref) {
  Future<void> _initializeToken() async {
    final token = await FirebaseMessaging.instance.getToken();
    if (token != null) {
      ref.read(fcmTokenProvider.notifier).state = token;

      await FirebaseFirestore.instance.collection('tokens').doc(token).set({
        'token': token,
        'createdAt': FieldValue.serverTimestamp(),
      });

      await FirebaseMessaging.instance.subscribeToTopic('all');
      print('Subscribed to topic: all');
    }

    // Token refresh listener
    FirebaseMessaging.instance.onTokenRefresh.listen((newToken) async {
      ref.read(fcmTokenProvider.notifier).state = newToken;

      await FirebaseFirestore.instance.collection('tokens').doc(newToken).set({
        'token': newToken,
        'refreshedAt': FieldValue.serverTimestamp(),
      });

      await FirebaseMessaging.instance.subscribeToTopic('all');
      print(' Token refreshed & re-subscribed to topic: all');
    });
  }

  _initializeToken(); // Call on provider init
});
