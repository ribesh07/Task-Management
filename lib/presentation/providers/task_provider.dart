import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/task_datasource.dart';
import '../../data/models/task_model.dart';

final taskDatasourceProvider = Provider((ref) => TaskDatasource());

final taskStreamProvider = StreamProvider<List<TaskModel>>((ref) {
  return ref.read(taskDatasourceProvider).getTasks();
});

final hoveredStatusProvider = StateProvider<String?>((ref) => null);
final draggedTaskProvider = StateProvider<TaskModel?>((ref) => null);
