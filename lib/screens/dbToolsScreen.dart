import 'dart:convert';
import 'dart:io';
import 'package:csv/csv.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_file_dialog/flutter_file_dialog.dart';


class DbToolsScreen extends StatefulWidget {
  const DbToolsScreen({Key? key}) : super(key: key);

  @override
  State<DbToolsScreen> createState() => _DbToolsScreenState();
}

class _DbToolsScreenState extends State<DbToolsScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  void _showMessage(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }


  Future<void> _backupDatabase() async {
    try {
      // Obtener usuarios que no son administradores
      final snapshot = await _firestore
          .collection('users')
          .where('role', isNotEqualTo: 'administrador')
          .get();

      // Construir lista de mapas con los datos
      List<Map<String, dynamic>> users = [];

      for (var doc in snapshot.docs) {
        var data = doc.data();

        final createdAt = data['createdAt'];
        String? createdAtString;

        if (createdAt != null && createdAt is Timestamp) {
          createdAtString = createdAt.toDate().toIso8601String(); // convierte a formato ISO
        }

        users.add({
          'createdAt': createdAtString ?? '',
          'email': data['email'],
          'name': data['name'],
          'phone': data['phone'],
          'role': data['role'],
          'id': doc.id, // opcional
        });
      }

      // Convertir a JSON
      String jsonData = jsonEncode(users);

      // Guardar temporalmente el archivo
      final dir = await getTemporaryDirectory();
      final path = '${dir.path}/usuarios_no_admin.json';
      final file = File(path);
      await file.writeAsString(jsonData);

      // Usar flutter_file_dialog para que el usuario elija dónde guardar
      final params = SaveFileDialogParams(
        sourceFilePath: file.path,
        fileName: 'usuarios_no_administradores.json',
      );
      final savedPath = await FlutterFileDialog.saveFile(params: params);

      if (savedPath != null) {
        _showMessage('Backup creado correctamente en:\n$savedPath');
      } else {
        _showMessage('Exportación cancelada por el usuario');
      }
    } catch (e) {
      _showMessage('Error en backup: $e');
    }
  }


  Future<void> _restoreDatabase() async {
    try {
      // Selección del archivo JSON
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
      );

      if (result == null || result.files.single.path == null) {
        _showMessage('Restauración cancelada.');
        return;
      }

      final path = result.files.single.path!;
      final file = File(path);
      final content = await file.readAsString();

      // Parseo del contenido JSON
      final List<dynamic> users = jsonDecode(content);

      if (users.isEmpty) {
        _showMessage('Archivo JSON vacío o inválido.');
        return;
      }

      // Eliminar usuarios que NO son administradores
      final snapshot = await _firestore.collection('users')
          .where('role', isNotEqualTo: 'administrador')
          .get();

      for (var doc in snapshot.docs) {
        await doc.reference.delete();
      }

      // Restaurar usuarios desde el JSON (solo los que no son administradores)
      for (var user in users) {
        if (user['role'] == 'administrador') continue;

        final id = user['id'] ?? _firestore.collection('users').doc().id;

        await _firestore.collection('users').doc(id).set({
          'email': user['email'] ?? '',
          'name': user['name'] ?? '',
          'phone': user['phone'] ?? '',
          'role': user['role'] ?? '',
          'createdAt': user['createdAt'] != null
              ? Timestamp.fromDate(DateTime.parse(user['createdAt']))
              : FieldValue.serverTimestamp(),
        });
      }

      _showMessage('Restauración completada. Usuarios no administradores reemplazados.');
    } catch (e) {
      _showMessage('Error en restauración: $e');
    }
  }


  Future<void> _deleteNonAdminUsers() async {
    final snapshot = await _firestore.collection('users').get();

    for (var doc in snapshot.docs) {
      final data = doc.data();
      if (data['rol'] != 'admin') {
        String uid = doc.id;

        await _firestore.collection('users').doc(uid).delete();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final tools = [
      'Backup de base de datos',
      'Restaurar base de datos',
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Herramientas de Base de Datos'),
      ),
      body: Padding(
        padding: const EdgeInsets.only(top: 16.0),
        child: Align(
          alignment: Alignment.topCenter,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: tools.map((toolName) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: ElevatedButton(
                  onPressed: () {
                    if (toolName == 'Backup de base de datos') {
                      _backupDatabase();
                    } else if (toolName == 'Restaurar base de datos') {
                      _restoreDatabase();
                    }
                  },
                  child: Text(toolName),
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}
