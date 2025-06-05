import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:task_management_app/data/repositories/chat_repository.dart';
import '../../data/datasources/task_datasource.dart';
import '../../data/models/task_model.dart';

final taskDatasourceProvider = Provider((ref) => TaskDatasource());

final taskStreamProvider = StreamProvider<List<TaskModel>>((ref) {
  return ref.read(taskDatasourceProvider).getTasks();
});

final hoveredStatusProvider = StateProvider<String?>((ref) => null);
final draggedTaskProvider = StateProvider<TaskModel?>((ref) => null);
final chatRepositoryProvider = Provider((ref) => ChatRepository());
final chatStreamProvider =
    StreamProvider.family<List<Map<String, dynamic>>, String>((ref, chatId) {
  return FirebaseFirestore.instance
      .collection('chats/$chatId/messages')
      .orderBy('timestamp', descending: true)
      .snapshots()
      .map((snap) => snap.docs
          .map((doc) => doc.data())
          .cast<Map<String, dynamic>>()
          .toList());
});
