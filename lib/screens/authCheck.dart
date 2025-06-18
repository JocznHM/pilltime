import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'homeScreen.dart';
import 'loginScreen.dart';

class AuthCheck extends StatelessWidget {
  const AuthCheck({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      // Usuario autenticado
      return const HomeScreen();
    } else {
      // Usuario no autenticado
      return LoginScreen();
    }
  }
}
