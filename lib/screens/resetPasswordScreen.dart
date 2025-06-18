import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController emailController = TextEditingController();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  bool isLoading = false;
  String? feedbackMessage;
  Color feedbackColor = Colors.transparent;

  Future<void> resetPassword() async {
    if (!formKey.currentState!.validate()) return;

    setState(() {
      isLoading = true;
      feedbackMessage = null;
    });

    final email = emailController.text.trim();

    try {
      await _auth.sendPasswordResetEmail(email: email);

      setState(() {
        feedbackMessage =
        'Si el correo está registrado, se ha enviado un enlace de recuperación.';
        feedbackColor = Colors.green;
      });

      await Future.delayed(const Duration(seconds: 2));
      if (mounted) Navigator.pop(context);
    } on FirebaseAuthException catch (_) {
      // No mostrar detalles específicos por seguridad
      setState(() {
        feedbackMessage =
        'Si el correo está registrado, se ha enviado un enlace de recuperación.';
        feedbackColor = Colors.green;
      });
    } finally {
      setState(() => isLoading = false);
    }
  }


  Widget _animatedFeedbackMessage() {
    return AnimatedOpacity(
      opacity: feedbackMessage == null ? 0.0 : 1.0,
      duration: const Duration(milliseconds: 300),
      child: feedbackMessage == null
          ? const SizedBox.shrink()
          : Container(
        margin: const EdgeInsets.only(top: 20),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: feedbackColor.withOpacity(0.1),
          border: Border.all(color: feedbackColor),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          feedbackMessage!,
          style: TextStyle(color: feedbackColor),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Restablecer contraseña')),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: formKey,
            child: Column(
              children: [
                Icon(Icons.lock_reset, size: 80, color: Theme.of(context).colorScheme.primary),
                const SizedBox(height: 16),
                Text(
                  'Recuperar contraseña',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 10),
                const Text(
                  'Ingresa tu correo electrónico para enviarte un enlace de recuperación.',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                TextFormField(
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: 'Correo electrónico',
                    prefixIcon: Icon(Icons.email_outlined),
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) =>
                  value == null || !value.contains('@') ? 'Correo inválido' : null,
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: FilledButton.icon(
                    icon: isLoading
                        ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                        : const Icon(Icons.send),
                    label: Text(isLoading ? 'Enviando...' : 'Enviar enlace'),
                    onPressed: isLoading ? null : resetPassword,
                  ),
                ),
                _animatedFeedbackMessage(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
