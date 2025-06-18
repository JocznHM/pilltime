import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class LogScreen extends StatelessWidget {
  const LogScreen({Key? key}) : super(key: key);

  String formatTimestamp(Timestamp? timestamp) {
    if (timestamp == null) return '-';
    final DateTime dateTime = timestamp.toDate();
    return DateFormat('yyyy-MM-dd HH:mm:ss').format(dateTime);
  }

  @override
  Widget build(BuildContext context) {
    final CollectionReference logsCollection =
    FirebaseFirestore.instance.collection('logs_sesion');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Logs de sesión'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream:
        logsCollection.orderBy('timestamp', descending: true).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final logs = snapshot.data?.docs ?? [];

          if (logs.isEmpty) {
            return const Center(child: Text('No hay registros de sesión'));
          }

          // Construir filas de la tabla
          final rows = logs.map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            final email = data['email'] ?? 'Desconocido';
            final accion = data['accion'] ?? 'N/A';
            final timestamp = data['timestamp'] as Timestamp?;
            final fechaFormateada = formatTimestamp(timestamp);

            return DataRow(
              cells: [
                DataCell(Text(email)),
                DataCell(Row(
                  children: [
                    Icon(
                      accion == 'inicio_sesion' ? Icons.login : Icons.logout,
                      color: accion == 'inicio_sesion'
                          ? Colors.green
                          : Colors.red,
                      size: 18,
                    ),
                    const SizedBox(width: 6),
                    Text(accion.replaceAll('_', ' ')),
                  ],
                )),
                DataCell(Text(fechaFormateada)),
              ],
            );
          }).toList();

          return Align(
            alignment: Alignment.topCenter,
            child: SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  columns: const [
                    DataColumn(label: Text('Usuario')),
                    DataColumn(label: Text('Acción')),
                    DataColumn(label: Text('Fecha y Hora')),
                  ],
                  rows: rows,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
