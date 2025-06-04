import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:task_management_app/data/models/task_model.dart';
import 'package:task_management_app/domain/services/sendfcm.dart';
import 'package:task_management_app/presentation/providers/task_provider.dart';

class EditTaskDialog extends StatefulWidget {
  final WidgetRef ref;
  final TaskModel task;

  EditTaskDialog({required this.ref, required this.task});

  @override
  _EditTaskDialogState createState() => _EditTaskDialogState();
}

class _EditTaskDialogState extends State<EditTaskDialog> {
  late TextEditingController _descController;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _descController = TextEditingController(text: widget.task.description);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.lightBlue[100],
      // shadowColor: Colors.blue,
      surfaceTintColor: Colors.blue[100],
      elevation: 60,
      title: const Text(
        'Edit Description',
        textAlign: TextAlign.center,
      ),
      content: Form(
        key: _formKey,
        child: TextFormField(
            controller: _descController,
            maxLines: 4,
            validator: (value) => value == null || value.trim().isEmpty
                ? 'Description required'
                : null,
            decoration: const InputDecoration(
              labelText: 'Description',
              hintStyle: TextStyle(color: Colors.grey),
              border: OutlineInputBorder(),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.blue, width: 2.0),
              ),
            )),
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
              widget.ref.read(taskDatasourceProvider).updateTaskDescription(
                  widget.task.id, _descController.text.trim());

              await sendFCMToAllTokens(
                title: 'Task Status Updated',
                body:
                    'Task "${widget.task.title}" updated to ${widget.task.description}',
              );
              Navigator.pop(context);
            }
          },
          child: const Text('Update'),
        )
      ],
    );
  }
}
