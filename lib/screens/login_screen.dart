import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final AuthService _authService = AuthService();
  final TextEditingController _email = TextEditingController();
  final TextEditingController _password = TextEditingController();

  bool isLogin = true;

  Future<void> _submit() async {
    try {
      if (isLogin) {
        await _authService.login(_email.text, _password.text);
      } else {
        await _authService.register(_email.text, _password.text);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(controller: _email, decoration: const InputDecoration(labelText: "Email")),
            TextField(controller: _password, decoration: const InputDecoration(labelText: "Password"), obscureText: true),
            const SizedBox(height: 20),
            ElevatedButton(onPressed: _submit, child: Text(isLogin ? "Login" : "Register")),
            TextButton(
              onPressed: () => setState(() => isLogin = !isLogin),
              child: Text(isLogin ? "Create account" : "Already have account"),
            )
          ],
        ),
      ),
    );
  }
}