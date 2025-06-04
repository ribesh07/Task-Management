import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:task_management_app/presentation/widgets/add_taskDialog.dart';
import 'package:task_management_app/presentation/widgets/edit_taskDialog.dart';
// import 'package:uuid/uuid.dart';
import '../providers/task_provider.dart';
import '../../data/models/task_model.dart';

class HomePage extends ConsumerWidget {
  final List<String> stages = ['Pending', 'Running', 'Testing', 'Completed'];

  HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    AsyncValue<List<TaskModel>> taskAsync = ref.watch(taskStreamProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Task Management',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w600,
            )),
        // centerTitle: true,
        backgroundColor: Colors.blue,
        actions: [
          IconButton(
            icon: const Icon(
              Icons.refresh,
              color: Colors.black,
              size: 30,
            ),
            onPressed: () {
              taskAsync = ref.refresh(taskStreamProvider);
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () {
          showDialog(context: context, builder: (_) => AddTaskDialog(ref: ref));
        },
      ),
      body: taskAsync.when(
        data: (tasks) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            child: Row(
              children: stages.map((status) {
                final filtered =
                    tasks.where((t) => t.status == status).toList();
                return SizedBox(
                  width: MediaQuery.of(context).size.width * 0.8,
                  child: Column(
                    children: [
                      Text(status,
                          style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue)),
                      Expanded(
                        child: ListView.builder(
                          itemCount: filtered.length,
                          itemBuilder: (_, i) {
                            final task = filtered[i];
                            return Card(
                              margin: const EdgeInsets.all(8),
                              // child: ListTile(
                              //   title: Text(task.title,
                              //       style: const TextStyle(
                              //           fontSize: 18,
                              //           fontWeight: FontWeight.w500)),
                              //   subtitle: Text(task.description,
                              //       style: const TextStyle(fontSize: 16)),
                              //   trailing: status != 'Completed'
                              //       ? ElevatedButton(
                              //           onPressed: () {
                              //             final index = stages.indexOf(status);
                              //             final next = stages[index + 1];
                              //             ref
                              //                 .read(taskDatasourceProvider)
                              //                 .updateTaskStatus(task.id, next);
                              //           },
                              //           child: Text(
                              //               'Move to ${stages[stages.indexOf(status) + 1]}'),
                              //         )
                              //       : null,
                              // ),

                              child: Container(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(task.title,
                                        style: const TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.w500)),
                                    const SizedBox(height: 8),
                                    Text(task.description,
                                        style: const TextStyle(fontSize: 16)),
                                    const SizedBox(height: 14),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        if (status != 'Completed')
                                          ElevatedButton(
                                            onPressed: () {
                                              final index =
                                                  stages.indexOf(status);
                                              final next = stages[index + 1];
                                              ref
                                                  .read(taskDatasourceProvider)
                                                  .updateTaskStatus(
                                                      task.id, next);
                                            },
                                            child: Text(
                                                'Move to ${stages[stages.indexOf(status) + 1]}'),
                                          ),
                                        if (status != 'Completed')
                                          IconButton(
                                            icon: const Icon(Icons.delete,
                                                color: Colors.red),
                                            onPressed: () {
                                              ref
                                                  .read(taskDatasourceProvider)
                                                  .deleteTask(task.id);
                                            },
                                          ),
                                        if (status != 'Completed')
                                          IconButton(
                                            icon: const Icon(Icons.edit,
                                                color: Colors.blue),
                                            onPressed: () {
                                              showDialog(
                                                context: context,
                                                builder: (_) => EditTaskDialog(
                                                    ref: ref, task: task),
                                              );
                                            },
                                          ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }
}
