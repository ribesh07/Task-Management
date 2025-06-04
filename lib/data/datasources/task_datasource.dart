// ignore_for_file: avoid_print

import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/task_model.dart';

class TaskDatasource {
  final _collection = FirebaseFirestore.instance.collection('tasks');

  Stream<List<TaskModel>> getTasks() {
    return _collection.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return TaskModel.fromMap(doc.id, doc.data());
      }).toList();
    });
  }

  Future<void> addTask(TaskModel task) {
    return _collection.add(task.toMap());
  }

  Future<void> updateTaskStatus(String id, String newStatus) {
    return _collection.doc(id).update({'status': newStatus});
  }

  Future<void> deleteTask(String id) {
    return _collection.doc(id).delete();
  }

  void updateTaskDescription(String id, String description) {
    _collection
        .doc(id)
        .update({'description': description}).catchError((error) {
      print('Failed to update task description: $error');
    });
  }
}
