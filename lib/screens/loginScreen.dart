import 'package:flutter/material.dart';
import '/controllers/loginController.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  late LoginController _controller;

  @override
  void initState() {
    super.initState();
    _controller = LoginController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _controller.formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/pilltimeLogo.png',
                  width: 120,
                  height: 120,
                ),
                const SizedBox(height: 30),

                Text(
                  'Iniciar sesión',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 10),

                TextFormField(
                  controller: _controller.emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: 'Correo electrónico',
                    prefixIcon: Icon(Icons.email_outlined),
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Ingresa tu correo';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                TextFormField(
                  controller: _controller.passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Contraseña',
                    prefixIcon: Icon(Icons.lock_outline),
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Ingresa tu contraseña';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                DropdownButtonFormField<String>(
                  value: _controller.selectedRole,
                  items: const [
                    DropdownMenuItem(value: 'Paciente', child: Text('Paciente')),
                    DropdownMenuItem(value: 'Administrador', child: Text('Administrador')),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _controller.setRole(value);
                      });
                    }
                  },
                  decoration: const InputDecoration(
                    labelText: 'Rol',
                    prefixIcon: Icon(Icons.person_outline),
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 24),

                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: FilledButton.icon(
                    icon: const Icon(Icons.login),
                    label: const Text('Iniciar sesión'),
                    onPressed: () => _controller.login(context),
                  ),
                ),
                const SizedBox(height: 12),

                TextButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/resetPassword');
                  },
                  child: const Text('¿Olvidaste tu contraseña?'),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/register');
                  },
                  child: const Text('¿No tienes una cuenta? Regístrate'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
