import 'package:flutter/material.dart';
import '../controllers/auth_controller.dart';
import 'expense_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _auth = AuthController();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  void _toast(String msg) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(msg)));
  }

  Future<void> _signIn() async {
    final email = _emailCtrl.text.trim();
    final pass = _passCtrl.text;
    if (email.isEmpty || pass.isEmpty) {
      _toast('Vui lòng nhập email và mật khẩu');
      return;
    }
    final ok = await _auth.login(email, pass);
    if (!mounted) return;
    if (ok) {
      _toast('Đăng nhập thành công');
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const ExpenseScreen()),
      );
    } else {
      _toast('Sai email hoặc mật khẩu');
    }
  }

  Future<void> _register() async {
    final error = await _auth.register(_emailCtrl.text.trim(), _passCtrl.text);
    if (!mounted) return;
    if (error == null) {
      _toast('Đăng ký thành công, hãy đăng nhập');
      _passCtrl.clear();
    } else {
      _toast(error);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Email',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                _field(_emailCtrl, 'Value', false),
                const SizedBox(height: 16),
                const Text('Password',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                _field(_passCtrl, 'Value', true),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    FilledButton(
                        onPressed: _signIn, child: const Text('Sign in')),
                    FilledButton(
                        onPressed: _register, child: const Text('Register')),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _field(TextEditingController c, String hint, bool obscure) {
    return TextField(
      controller: c,
      obscureText: obscure,
      keyboardType:
          obscure ? TextInputType.text : TextInputType.emailAddress,
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: Colors.grey[200],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
