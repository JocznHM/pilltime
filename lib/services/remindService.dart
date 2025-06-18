import 'package:hive/hive.dart';
import '../models/reminder.dart';

class ReminderService {
  static final Box<Reminder> _box = Hive.box<Reminder>('reminders');

  static List<Reminder> getAllReminders() {
    return _box.values.toList();
  }

  static Future<void> addReminder(Reminder reminder) async {
    await _box.add(reminder);
  }

  static Future<void> updateReminder(int key, Reminder updatedReminder) async {
    await _box.put(key, updatedReminder);
  }

  static Future<void> deleteReminder(int key) async {
    await _box.delete(key);
  }

  static Reminder? getReminder(int key) {
    return _box.get(key);
  }

  static Map<dynamic, Reminder> getReminderMap() {
    return _box.toMap();
  }
}
