import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:task_management_app/presentation/widgets/add_taskDialog.dart';
import 'package:task_management_app/presentation/widgets/card.dart';
import '../providers/task_provider.dart';
import '../../data/models/task_model.dart';

class HomePage extends ConsumerWidget {
  final List<String> stages = ['Pending', 'Running', 'Testing', 'Completed'];

  HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    AsyncValue<List<TaskModel>> taskAsync = ref.watch(taskStreamProvider);

    Widget taskCardContent(
        TaskModel task, WidgetRef ref, BuildContext context) {
      return taskCard(task, ref, context, stages);
    }

    Widget buildTaskCard(TaskModel task, WidgetRef ref) {
      return LongPressDraggable<TaskModel>(
        data: task,
        feedback: Consumer(builder: (context, ref, _) {
          final draggedTask = ref.watch(draggedTaskProvider);
          return Material(
            color: Colors.transparent,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 350),
              child: Opacity(
                opacity: 0.7,
                child: taskCardDraggable(
                    hoveredTask: draggedTask, ref, context, stages),
              ),
            ),
          );
        }),
        childWhenDragging:
            Opacity(opacity: 0.4, child: taskCardContent(task, ref, context)),
        child: taskCardContent(task, ref, context),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Task Management',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w600,
            )),
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
            padding: const EdgeInsets.all(8),
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            child: Row(
              children: stages.map((status) {
                final filtered =
                    tasks.where((t) => t.status == status).toList();
                return DragTarget<TaskModel>(
                  onWillAcceptWithDetails: (details) {
                    final task = details.data;
                    return task.status != status;
                  },
                  onAcceptWithDetails: (details) {
                    final task = details.data;
                    ref
                        .read(taskDatasourceProvider)
                        .updateTaskStatus(task.id, status);
                    ref.read(hoveredStatusProvider.notifier).state = null;
                  },
                  onLeave: (details) {
                    ref.read(hoveredStatusProvider.notifier).state = null;
                  },
                  onMove: (details) {
                    ref.read(hoveredStatusProvider.notifier).state = status;
                    ref.read(draggedTaskProvider.notifier).state = details.data;
                  },
                  builder: (context, candidateData, rejectedData) {
                    return Container(
                      width: MediaQuery.of(context).size.width * 0.8,
                      margin: const EdgeInsets.symmetric(horizontal: 8),
                      decoration: BoxDecoration(
                        boxShadow: [
                          BoxShadow(
                            color: const Color.fromARGB(255, 36, 98, 192)
                                .withOpacity(0.9),
                            spreadRadius: 2,
                            blurRadius: 5,
                            offset: const Offset(0, 3),
                          ),
                        ],
                        color: Colors.blue[100],
                        borderRadius: BorderRadius.circular(8),
                        border: candidateData.isNotEmpty
                            ? Border.all(color: Colors.blue, width: 2)
                            : null,
                      ),
                      child: Column(
                        children: [
                          Text(status,
                              style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue)),
                          const SizedBox(height: 10),
                          Expanded(
                            child: ListView.builder(
                              itemCount: filtered.length,
                              itemBuilder: (_, i) {
                                final task = filtered[i];
                                return buildTaskCard(task, ref);
                              },
                            ),
                          ),
                        ],
                      ),
                    );
                  },
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
