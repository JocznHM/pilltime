import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AdminScreen extends StatelessWidget {
  const AdminScreen({Key? key}) : super(key: key);

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
  Future<void> _signOut(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushReplacementNamed(context, '/login');
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: const Text('Panel de Administrador'),
          actions: [
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert),
              onSelected: (String value) async {
                if (value == 'logout') {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Cerrando sesión...')),
                  );
                  await registrarLogSesion('cierre_sesion');
                  await _signOut(context);
                }
              },
              itemBuilder: (BuildContext context) => [
                PopupMenuItem<String>(
                  value: 'profile',
                  enabled: false,
                  child: ListTile(
                    leading: const Icon(Icons.person_outline),
                    title: Text(user?.email ?? 'Administrador'),
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
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.only(top: 40),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Center(
                  child: Text(
                    'Bienvenido, administrador${user != null ? '\n${user.email}' : ''}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 30),
                Center(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.manage_accounts),
                    label: const Text('Herramientas de base de datos de usuario'),
                    onPressed: () {
                      Navigator.pushNamed(context, '/dbTools');
                    },
                  ),
                ),
                const SizedBox(height: 10),
                Center(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.list_alt),
                    label: const Text('Log de inicio de sesión'),
                    onPressed: () {
                      Navigator.pushNamed(context, '/logs');
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
