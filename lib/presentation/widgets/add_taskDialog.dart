import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:task_management_app/data/models/task_model.dart';
import 'package:task_management_app/domain/services/sendfcm.dart';
import 'package:task_management_app/presentation/providers/task_provider.dart';

class AddTaskDialog extends StatefulWidget {
  final WidgetRef ref;

  const AddTaskDialog({super.key, required this.ref});

  @override
  _AddTaskDialogState createState() => _AddTaskDialogState();
}

class _AddTaskDialogState extends State<AddTaskDialog> {
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.lightBlue[100],
      // shadowColor: Colors.blue,
      surfaceTintColor: Colors.blue[50],

      title: const Text('Create Task'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _titleController,
              maxLength: 50,
              maxLines: 1,
              keyboardType: TextInputType.text,
              decoration: const InputDecoration(
                  labelText: 'Title',
                  hintStyle: TextStyle(color: Colors.grey),
                  border: OutlineInputBorder(),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.blue, width: 2.0),
                  )),
              validator: (value) => value == null || value.trim().isEmpty
                  ? 'Title required'
                  : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _descController,
              maxLines: 5,
              minLines: 3,
              maxLength: 200,
              keyboardType: TextInputType.multiline,
              decoration: const InputDecoration(
                  labelText: 'Description',
                  hintStyle: TextStyle(color: Colors.grey),
                  border: OutlineInputBorder(),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.blue, width: 2.0),
                  )),
              validator: (value) => value == null || value.trim().isEmpty
                  ? 'Description required'
                  : null,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel')),
        ElevatedButton(
          style: ButtonStyle(
            backgroundColor: WidgetStateProperty.all<Color>(Colors.blue),
            foregroundColor: WidgetStateProperty.all<Color>(Colors.white),
          ),
          onPressed: () async {
            if (_formKey.currentState!.validate()) {
              final task = TaskModel(
                id: '', // Firebase or your DB should auto-generate ID
                title: _titleController.text.trim(),
                description: _descController.text.trim(),
                status: 'Pending',
              );
              widget.ref.read(taskDatasourceProvider).addTask(task);
              await sendFCMToAllTokens(
                title: 'Task Status Updated',
                body: 'Task "${task.title}" for ${task.description}',
              );
              Navigator.pop(context);
            }

            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Task added to Pending '),
                behavior: SnackBarBehavior.floating,
                backgroundColor: Colors.blue,
                duration: Duration(seconds: 2),
              ),
            );
          },
          child: const Text('Add'),
        )
      ],
    );
  }
}
