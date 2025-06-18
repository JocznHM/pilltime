import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


class LoginController {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController roleController = TextEditingController();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  String selectedRole = 'Paciente';

  void setRole(String role) {
    selectedRole = role;
  }

  bool validateForm() {
    return formKey.currentState?.validate() ?? false;
  }

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

  Future<void> login(BuildContext context) async {
    if (!validateForm()) return;

    final email = emailController.text.trim();
    final password = passwordController.text;
    final role = selectedRole.toLowerCase(); // usar selectedRole correctamente

    print('Email: $email');
    print('Password: $password');
    print('Role: $role');
    print('Selected Role: $selectedRole');

    try {
      // Autenticación con Firebase
      UserCredential userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);

      // Buscar el usuario por email en Firestore
      final querySnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('email', isEqualTo: email)
          .limit(1)
          .get();

      if (querySnapshot.docs.isEmpty) {
        throw FirebaseAuthException(code: 'user-not-found');
      }

      final userDoc = querySnapshot.docs.first;
      final data = userDoc.data();
      final roleDb = data['role']?.toString().toLowerCase();

      // Validar que el rol seleccionado coincida con el del documento en Firestore
      if (roleDb != role) {
        await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Rol incorrecto'),
            content: Text('El rol seleccionado no coincide con el usuario.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text('Cerrar'),
              ),
            ],
          ),
        );
        await FirebaseAuth.instance.signOut();
        return;
      }

      // Mostrar éxito y redirigir según el rol
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Inicio de sesión exitoso")),
      );

      if (role == 'administrador') {
        await registrarLogSesion('inicio_sesion');
        Navigator.pushReplacementNamed(context, '/dashboardAdmin');

      } else {
        await registrarLogSesion('inicio_sesion');
        Navigator.pushReplacementNamed(context, '/dashboard');
      }

    } on FirebaseAuthException catch (e) {
      String errorMessage = 'Error al iniciar sesión';
      if (e.code == 'user-not-found') {
        errorMessage = 'Usuario no encontrado';
      } else if (e.code == 'wrong-password') {
        errorMessage = 'Contraseña incorrecta';
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMessage)),
      );
    }
  }

  /*Future<void> login(BuildContext context) async {
    if (!validateForm()) return;

    final email = emailController.text.trim();
    final password = passwordController.text;
    final role = roleController.text;

    try {
      // Autenticación real con Firebase
      // se verifica si el usuario es paciente o administrador
      //si el usuario en la db es administrador pero el rol seleccionado es paciente, se muestra un mensaje de error
      //donde indica que el rol seleccionado no es compatible con el usuario
      //si el usuario en la db es paciente pero el rol seleccionado es administrador, se muestra un mensaje de error
      //donde indica que el rol seleccionado no es compatible con el usuario
      //si el usuario en la db es paciente y el rol seleccionado es paciente, se realiza el inicio de sesión redireccionando
      //al dashboard
      //si el usuario en la db es administrador y el rol seleccionado es administrador, se realiza el inicio de sesión redireccionando
      //al dashboard de admin


    } on FirebaseAuthException catch (e) {
      String errorMessage = 'Error al iniciar sesión';
      if (e.code == 'user-not-found') {
        errorMessage = 'Usuario no encontrado';
      } else if (e.code == 'wrong-password') {
        errorMessage = 'Contraseña incorrecta';
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMessage)),
      );
    }
  }*/

  void dispose() {
    emailController.dispose();
    passwordController.dispose();
  }
}
