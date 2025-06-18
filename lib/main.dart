import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

import 'package:hive_flutter/hive_flutter.dart';
import 'models/reminder.dart';

// Screens
import 'screens/loginScreen.dart';
import 'screens/registerScreen.dart';
import 'screens/homeScreen.dart';
import 'screens/authCheck.dart';
import 'screens/resetPasswordScreen.dart';
import 'screens/adminScreen.dart';
import 'screens/logScreen.dart';
import 'screens/dbToolsScreen.dart';
import 'package:awesome_notifications/awesome_notifications.dart';

// Agrega import de permission_handler
import 'package:permission_handler/permission_handler.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Pedir permiso de almacenamiento aquí
  await _requestStoragePermission();

  // Inicializar Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Inicializar Hive
  await Hive.initFlutter();
  Hive.registerAdapter(ReminderAdapter());
  await Hive.openBox<Reminder>('reminders');

  // Inicializa awesome notifications
  AwesomeNotifications().initialize(
    null,
    [
      NotificationChannel(
        channelKey: 'medic_reminders',
        channelName: 'Recordatorios de Medicamentos',
        channelDescription: 'Notificaciones para tomar medicamentos',
        defaultColor: const Color(0xFF9D50DD),
        ledColor: Colors.white,
        importance: NotificationImportance.High,
        channelShowBadge: true,
      )
    ],
    debug: true,
  );

  await AwesomeNotifications().isNotificationAllowed().then((isAllowed) {
    if (!isAllowed) {
      AwesomeNotifications().requestPermissionToSendNotifications();
    }
  });

  // Pedir permiso de almacenamiento
  var status = await Permission.storage.status;
  if (!status.isGranted) {
    await Permission.storage.request();
  }

  runApp(const MyApp());
}

Future<void> _requestStoragePermission() async {
  var status = await Permission.storage.status;
  if (!status.isGranted) {
    await Permission.storage.request();
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PillTime',
      debugShowCheckedModeBanner: false,
      home: const AuthCheck(), // Verifica si hay sesión activa
      routes: {
        '/login': (context) => LoginScreen(),
        '/register': (context) => RegisterScreen(),
        '/dashboard': (context) => const HomeScreen(),
        '/dashboardAdmin': (context) => const AdminScreen(),
        '/resetPassword': (context) => const ResetPasswordScreen(),
        '/logs': (context) => const LogScreen(),
        '/dbTools': (context) => const DbToolsScreen(),
      },
    );
  }
}
