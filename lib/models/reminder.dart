import 'package:hive/hive.dart';

part 'reminder.g.dart';

@HiveType(typeId: 0)
class Reminder extends HiveObject {
  @HiveField(0)
  String medicineName;

  @HiveField(1)
  String dose;

  @HiveField(2)
  int intervalMinutes;

  @HiveField(3) // ¡Nuevo campo para el ID de la notificación!
  late int id; // Usaremos este como el ID de la notificación

  // Puedes añadir un campo para la hora de la primera dosis si tu lógica lo requiere
  @HiveField(4)
  late DateTime firstDoseTime;


  Reminder({
    required this.medicineName,
    required this.dose,
    required this.intervalMinutes,
    required this.id, // Ahora se requiere al crear un Reminder
    required this.firstDoseTime, // Requerido para calcular la hora de la próxima dosis
  });
}