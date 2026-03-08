import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  bool isLogin = true;
  final _formKey = GlobalKey<FormState>();
  String email = '';
  String password = '';
  String name = '';
  String error = '';
  bool loading = false;

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();
    setState(() { loading = true; error = ''; });
    final url = isLogin
        ? 'http://localhost:3000/api/auth/login'
        : 'http://localhost:3000/api/auth/register';
    final body = isLogin
        ? {'email': email, 'password': password}
        : {'name': name, 'email': email, 'password': password};
    try {
      final res = await http.post(Uri.parse(url),
          headers: {'Content-Type': 'application/json'},
          body: json.encode(body));
      final data = json.decode(res.body);
      if (res.statusCode == 200 && data['token'] != null) {
        // Save token (implement secure storage in production)
        Navigator.of(context).pop(data['token']);
      } else {
        setState(() { error = data['message'] ?? 'Auth failed'; });
      }
    } catch (e) {
      setState(() { error = 'Network error'; });
    }
    setState(() { loading = false; });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(isLogin ? 'Login' : 'Register')),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (!isLogin)
                  TextFormField(
                    decoration: InputDecoration(labelText: 'Name'),
                    onSaved: (v) => name = v ?? '',
                    validator: (v) => v == null || v.isEmpty ? 'Enter name' : null,
                  ),
                TextFormField(
                  decoration: InputDecoration(labelText: 'Email'),
                  onSaved: (v) => email = v ?? '',
                  validator: (v) => v == null || !v.contains('@') ? 'Enter valid email' : null,
                ),
                TextFormField(
                  decoration: InputDecoration(labelText: 'Password'),
                  obscureText: true,
                  onSaved: (v) => password = v ?? '',
                  validator: (v) => v == null || v.length < 6 ? 'Min 6 chars' : null,
                ),
                const SizedBox(height: 16),
                if (error.isNotEmpty)
                  Text(error, style: TextStyle(color: Colors.red)),
                const SizedBox(height: 16),
                loading
                    ? CircularProgressIndicator()
                    : ElevatedButton(
                        onPressed: _submit,
                        child: Text(isLogin ? 'Login' : 'Register'),
                      ),
                TextButton(
                  onPressed: () => setState(() => isLogin = !isLogin),
                  child: Text(isLogin ? 'No account? Register' : 'Have account? Login'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
