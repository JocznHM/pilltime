import 'package:flutter/material.dart';
import '../models/reminder.dart';

class ReminderTile extends StatelessWidget {
  final Reminder reminder;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const ReminderTile({
    Key? key,
    required this.reminder,
    required this.onEdit,
    required this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(reminder.medicineName),
      subtitle: Text('${reminder.dose} Cada ${reminder.intervalMinutes} minutos'),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: onEdit,
            tooltip: 'Editar',
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: onDelete,
            tooltip: 'Eliminar',
          ),
        ],
      ),
    );
  }
}
