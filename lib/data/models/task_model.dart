import '../../domain/entities/task_entity.dart';

class TaskModel extends TaskEntity {
  TaskModel({
    required super.id,
    required super.title,
    required super.description,
    required super.status,
  });

  factory TaskModel.fromMap(String id, Map<String, dynamic> data) {
    return TaskModel(
      id: id,
      title: data['title'],
      description: data['description'],
      status: data['status'],
    );
  }

  Map<String, dynamic> toMap() => {
        'title': title,
        'description': description,
        'status': status,
      };
}
