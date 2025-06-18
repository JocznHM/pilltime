import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../models/reminder.dart';
import '../widgets/reminder_tile.dart';
import 'package:awesome_notifications/awesome_notifications.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Box<Reminder> reminderBox;

  @override
  void initState() {
    super.initState();
    reminderBox = Hive.box<Reminder>('reminders');
  }

  //funcion que se encarga de agendar las notificaciones
  Future<void> scheduleReminderNotification(Reminder reminder) async {
    final String localTimeZone = await AwesomeNotifications().getLocalTimeZoneIdentifier();
    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: reminder.id,
        channelKey: 'medic_reminders',
        title: 'Hora de tomar tu medicamento',
        body: '${reminder.medicineName} - Dosis: ${reminder.dose}',
        notificationLayout: NotificationLayout.Default,
      ),
      schedule: NotificationInterval(
        interval: Duration(minutes: reminder.intervalMinutes),
        timeZone: await AwesomeNotifications().getLocalTimeZoneIdentifier(),
        repeats: true,
        preciseAlarm: true,
      ),
    );
  }
  /*void scheduleReminderNotification(Reminder reminder) {
    AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: reminder.id,
        channelKey: 'medic_reminders',
        title: 'Hora de tomar tu medicamento',
        body: '${reminder.medicineName} - Dosis: ${reminder.dose}',
        notificationLayout: NotificationLayout.Default,
      ),
      schedule: NotificationCalendar(
        year: reminder.firstDoseTime.year,
        month: reminder.firstDoseTime.month,
        day: reminder.firstDoseTime.day,
        hour: reminder.firstDoseTime.hour,
        minute: reminder.firstDoseTime.minute,
        second: 0,
        millisecond: 0,
        repeats: true,
        preciseAlarm: true,
      ),
    );
  }
  */
  static Future<void> registrarLogSesion(String accion) async {
    final FirebaseFirestore _firestore = FirebaseFirestore.instance;
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await _firestore.collection('logs_sesion').add({
        'userId': user.uid,
        'email': user.email,
        'accion': accion, // Por ejemplo: 'inicio_sesion' o 'cierre_sesion'
        'timestamp': FieldValue.serverTimestamp(),
      });
    }
  }

  //funcion que se encarga de mostrar el dialogo para agregar o editar un recordatorio
  Future<void> _showReminderDialog({Reminder? existing, int? index}) async {
    final TextEditingController nameController = TextEditingController(text: existing?.medicineName ?? '');
    final TextEditingController doseController = TextEditingController(text: existing?.dose ?? '');
    final TextEditingController intervalController = TextEditingController(text: existing?.intervalMinutes.toString() ?? '');

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(existing == null ? 'Agregar recordatorio' : 'Editar recordatorio'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Nombre del medicamento'),
            ),
            TextField(
              controller: doseController,
              decoration: const InputDecoration(labelText: 'Dosis'),
              keyboardType: TextInputType.text,
            ),
            TextField(
              controller: intervalController,
              decoration: const InputDecoration(labelText: 'Intervalo en minutos'),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              final String name = nameController.text.trim();
              final String dose = doseController.text.trim();
              final int? interval = int.tryParse(intervalController.text.trim());

              if (name.isNotEmpty && dose.isNotEmpty && interval != null) {
                if (existing == null) {
                  final int id = DateTime.now().millisecondsSinceEpoch.remainder(1 << 31);
                  final DateTime now = DateTime.now();

                  final reminder = Reminder(
                    medicineName: name,
                    dose: dose,
                    intervalMinutes: interval,
                    id: id,
                    firstDoseTime: now,
                  );

                  reminderBox.add(reminder);
                  scheduleReminderNotification(reminder);
                } else if (index != null) {
                  final updatedReminder = Reminder(
                    medicineName: name,
                    dose: dose,
                    intervalMinutes: interval,
                    id: existing.id,
                    firstDoseTime: existing.firstDoseTime,
                  );

                  reminderBox.putAt(index, updatedReminder);
                }

                setState(() {});
                Navigator.pop(context);
              }
            },
            child: const Text('Guardar'),
          )
        ],
      ),
    );
  }



  void _editReminder(int index) {
    final reminder = reminderBox.getAt(index);
    if (reminder != null) {
      _showReminderDialog(existing: reminder, index: index);
    }
  }

  void _deleteReminder(int index) {
    final reminder = reminderBox.getAt(index);
    AwesomeNotifications().cancel(reminder!.id);
    reminderBox.deleteAt(index);
    setState(() {});
  }

  void _addReminder() {
    _showReminderDialog();
  }

  @override
  Widget build(BuildContext context) {
    final User? user = FirebaseAuth.instance.currentUser;

    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: const Text('Inicio'),
          actions: [
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert),
              onSelected: (String value) async {
                switch (value) {
                  case 'profile':
                    //Navigator.pushNamed(context, '/profile');
                    break;
                  case 'importExport':
                    //Navigator.pushNamed(context, '/importExport');
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Error intente más tarde")),
                    );
                    break;
                  case 'logout':
                    await registrarLogSesion('cierre_sesion');
                    await FirebaseAuth.instance.signOut();
                    Navigator.pushReplacementNamed(context, '/login');
                    break;
                }
              },
              itemBuilder: (BuildContext context) => [
                PopupMenuItem<String>(
                  value: 'profile',
                  child: ListTile(
                    leading: Icon(Icons.person_outline),
                    //se agrega el email del usuario
                    title: Text('${FirebaseAuth.instance.currentUser?.email}'),
                  ),
                ),
                const PopupMenuItem<String>(
                  value: 'importExport',
                  child: ListTile(
                    leading: Icon(Icons.swap_horiz),
                    title: Text('Importar / Exportar'),
                  ),
                ),
                const PopupMenuDivider(),
                const PopupMenuItem<String>(
                  value: 'logout',
                  child: ListTile(
                    leading: Icon(Icons.logout),
                    title: Text('Cerrar sesión'),
                  ),
                ),
              ],
            ),
          ],
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Text(
                '¡Bienvenido!',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            Expanded(
              child: ValueListenableBuilder(
                valueListenable: reminderBox.listenable(),
                builder: (context, Box<Reminder> box, _) {
                  if (box.isEmpty) {
                    return const Center(child: Text('No hay recordatorios.'));
                  }
                  return ListView.builder(
                    itemCount: box.length,
                    itemBuilder: (context, index) {
                      final reminder = box.getAt(index)!;
                      return ReminderTile(
                        reminder: reminder,
                        onEdit: () => _editReminder(index),
                        onDelete: () => _deleteReminder(index),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: _addReminder,
          child: const Icon(Icons.add),
        ),
      ),
    );
  }
}
