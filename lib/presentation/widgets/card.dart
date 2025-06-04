import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:task_management_app/data/models/task_model.dart';
import 'package:task_management_app/presentation/providers/task_provider.dart';
import 'package:task_management_app/presentation/widgets/edit_taskDialog.dart';

Widget taskCard(
    TaskModel task, WidgetRef ref, BuildContext context, List<String> stages) {
  return Card(
    margin: const EdgeInsets.all(8),
    child: Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(task.title,
              style:
                  const TextStyle(fontSize: 18, fontWeight: FontWeight.w500)),
          const SizedBox(height: 8),
          Text(task.description, style: const TextStyle(fontSize: 16)),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (task.status != 'Completed')
                ElevatedButton(
                  onPressed: () {
                    final index = stages.indexOf(task.status);
                    final next = stages[index + 1];
                    ref
                        .read(taskDatasourceProvider)
                        .updateTaskStatus(task.id, next);
                  },
                  child: Text(
                      'Move to ${stages[stages.indexOf(task.status) + 1]}'),
                ),
              if (task.status != 'Completed')
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () {
                    ref.read(taskDatasourceProvider).deleteTask(task.id);
                  },
                ),
              if (task.status != 'Completed')
                IconButton(
                  icon: const Icon(Icons.edit, color: Colors.blue),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (_) => EditTaskDialog(ref: ref, task: task),
                    );
                  },
                ),
            ],
          ),
        ],
      ),
    ),
  );
}
