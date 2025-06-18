import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
/*Controller for register*/
class RegisterController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> registerUser(
      BuildContext context, {
        required String name,
        required String email,
        required String phone,
        required String password,
      }) async {
    try {
      //  Registro en Firebase Auth
      // Se llama a la API de firebase para registrar el correo y la contraseña
      // En automatico Firebase la encripta
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Guardar info extra en Firestore
      // Basicamente la información extra es la información del usuario
      await _firestore.collection('users').doc(userCredential.user!.uid).set({
        'name': name,
        'email': email,
        'phone': phone,
        'role': "paciente",
        'createdAt': Timestamp.now(),
      });

      //  Registro exitoso
      //  Una vez registrado todos los datos se redirecciona al login donde si la sesion es valida
      //
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Registro exitoso')),
      );
      debugPrint("Se registro el usuario con exito");
      Navigator.pushReplacementNamed(context, '/login');
    }
    on FirebaseAuthException catch (e) {
      debugPrint("error");
      print(e);
      String message = 'Error al registrar';
      if (e.code == 'email-already-in-use') {
        message = 'El correo ya está en uso';
        debugPrint("El correo ya está en uso");
      } else if (e.code == 'weak-password') {
        message = 'La contraseña es muy débil';
        debugPrint("La contraseña es muy débil");
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    }
    catch (e) {
      print(e);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ocurrió un error inesperado')),
      );
    }
  }
}
