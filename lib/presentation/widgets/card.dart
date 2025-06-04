import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:task_management_app/data/models/task_model.dart';
import 'package:task_management_app/domain/services/sendfcm.dart';
import 'package:task_management_app/presentation/providers/task_provider.dart';
import 'package:task_management_app/presentation/widgets/edit_taskdialog.dart';

Widget taskCard(
    TaskModel task, WidgetRef ref, BuildContext context, List<String> stages) {
  final hoveredTask = ref.watch(draggedTaskProvider);
  return Card(
    shadowColor: Colors.blue,
    color: Colors.blue.shade50,
    surfaceTintColor: Colors.blue,
    elevation: 80,
    margin: const EdgeInsets.all(8),
    child: Container(
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        // gradient: LinearGradient(
        //   colors: [
        //     const Color.fromARGB(255, 170, 77, 193),
        //     const Color.fromARGB(255, 12, 138, 227)
        //   ],
        //   begin: Alignment.topLeft,
        //   end: Alignment.bottomRight,
        // ),
      ),
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
                  style: ButtonStyle(
                    elevation: WidgetStateProperty.all<double>(2),
                    enableFeedback: true,
                    backgroundColor:
                        WidgetStateProperty.all<Color>(Colors.blue.shade500),
                    foregroundColor:
                        WidgetStateProperty.all<Color>(Colors.white),
                  ),
                  onPressed: () async {
                    final index = stages.indexOf(task.status);
                    final next = stages[index + 1];
                    ref
                        .read(taskDatasourceProvider)
                        .updateTaskStatus(task.id, next);
                    await sendFCMToAllTokens(
                      title: 'Task Status Updated',
                      body: 'Task "${task.title}" moved to ${task.status}',
                    );
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Task moved to ${hoveredTask!.status}'),
                        behavior: SnackBarBehavior.floating,
                        backgroundColor: Colors.blue,
                        duration: Duration(seconds: 2),
                      ),
                    );
                  },
                  child: Text(
                      'Move to ${stages[stages.indexOf(task.status) + 1]}'),
                ),
              if (task.status != 'Completed')
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () {
                    AlertDialog alert = AlertDialog(
                      backgroundColor: Colors.blue[400],
                      surfaceTintColor: Colors.blue[50],
                      elevation: 60,
                      title: const Text('Delete Task'),
                      content: const Text(
                          'Are you sure you want to delete this task?'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Cancel'),
                        ),
                        ElevatedButton(
                          style: ButtonStyle(
                            backgroundColor:
                                WidgetStateProperty.all<Color>(Colors.red),
                            foregroundColor:
                                WidgetStateProperty.all<Color>(Colors.white),
                          ),
                          onPressed: () {
                            ref
                                .read(taskDatasourceProvider)
                                .deleteTask(task.id);
                            Navigator.pop(context);
                          },
                          child: const Text('Delete'),
                        ),
                      ],
                    );
                    showDialog(context: context, builder: (_) => alert);
                    // ref.read(taskDatasourceProvider).deleteTask(task.id);
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

Widget taskCardDraggable(
    WidgetRef ref, BuildContext context, List<String> stages,
    {TaskModel? hoveredTask}) {
  final draggedTask = ref.watch(hoveredStatusProvider);
  return Card(
    shadowColor: Colors.blue,
    color: Colors.blue,
    surfaceTintColor: Colors.blue,
    elevation: 70,
    margin: const EdgeInsets.all(8),
    child: Container(
      padding: const EdgeInsets.all(17),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(hoveredTask!.title,
              style:
                  const TextStyle(fontSize: 18, fontWeight: FontWeight.w500)),
          const SizedBox(height: 8),
          Text(hoveredTask.description, style: const TextStyle(fontSize: 16)),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (draggedTask != 'Completed')
                ElevatedButton(
                  style: ButtonStyle(
                    elevation: WidgetStateProperty.all<double>(2),
                    enableFeedback: true,
                    backgroundColor:
                        WidgetStateProperty.all<Color>(Colors.blue.shade500),
                    foregroundColor:
                        WidgetStateProperty.all<Color>(Colors.white),
                  ),
                  onPressed: () {},
                  child: Text('Move to $draggedTask'),
                ),
              if (hoveredTask.status != 'Completed')
                const Icon(Icons.delete, color: Colors.red),
              if (hoveredTask.status != 'Completed')
                const Icon(Icons.edit, color: Colors.blue),
            ],
          ),
        ],
      ),
    ),
  );
}
