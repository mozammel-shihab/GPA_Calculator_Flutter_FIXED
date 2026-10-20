import 'package:flutter/material.dart';

import '../services/app_store.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key, required this.store});

  final AppStore store;

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _id = TextEditingController();
  final _university = TextEditingController();
  bool _showEmailAuth = false;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _password.dispose();
    _id.dispose();
    _university.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    try {
      if (_showEmailAuth) {
        final hasName = _name.text.trim().isNotEmpty;
        if (hasName) {
          await widget.store.signUp(
            name: _name.text,
            email: _email.text,
            password: _password.text,
            id: _id.text,
            uni: _university.text,
          );
        } else {
          await widget.store.loginWithEmail(_email.text, _password.text);
        }
      } else {
        await widget.store.login(_name.text, _id.text, _university.text);
      }
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(error.toString().replaceFirst('Exception: ', ''))),
      );
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(28),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const CircleAvatar(
                        radius: 30,
                        child: Icon(Icons.school_rounded, size: 32),
                      ),
                      const SizedBox(height: 18),
                      Text(
                        'GPA Calculator Pro',
                        style: Theme.of(context)
                            .textTheme
                            .headlineMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Calculate GPA, track CGPA, save academic history and generate reports.',
                      ),
                      const SizedBox(height: 28),
                      TextFormField(
                        controller: _name,
                        textCapitalization: TextCapitalization.words,
                        decoration: const InputDecoration(
                          labelText: 'Student Name',
                          prefixIcon: Icon(Icons.person_outline),
                        ),
                        validator: (value) =>
                            value == null || value.trim().isEmpty
                                ? 'Please enter your name'
                                : null,
                      ),
                      const SizedBox(height: 14),
                      TextFormField(
                        controller: _id,
                        decoration: const InputDecoration(
                          labelText: 'Student ID (optional)',
                          prefixIcon: Icon(Icons.badge_outlined),
                        ),
                      ),
                      const SizedBox(height: 14),
                      TextFormField(
                        controller: _university,
                        decoration: const InputDecoration(
                          labelText: 'University (optional)',
                          prefixIcon: Icon(Icons.account_balance_outlined),
                        ),
                      ),
                      if (_showEmailAuth) ...[
                        const SizedBox(height: 14),
                        TextFormField(
                          controller: _email,
                          keyboardType: TextInputType.emailAddress,
                          decoration: const InputDecoration(
                            labelText: 'Email Address',
                            prefixIcon: Icon(Icons.email_outlined),
                          ),
                          validator: (value) {
                            if (!_showEmailAuth) return null;
                            if (value == null || value.trim().isEmpty) {
                              return 'Please enter your email';
                            }
                            final email = value.trim();
                            if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$')
                                .hasMatch(email)) {
                              return 'Please enter a valid email';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 14),
                        TextFormField(
                          controller: _password,
                          obscureText: true,
                          decoration: const InputDecoration(
                            labelText: 'Password',
                            prefixIcon: Icon(Icons.lock_outline),
                          ),
                          validator: (value) {
                            if (!_showEmailAuth) return null;
                            if (value == null || value.trim().isEmpty) {
                              return 'Please enter your password';
                            }
                            if (value.trim().length < 6) {
                              return 'Password must be at least 6 characters';
                            }
                            return null;
                          },
                        ),
                      ],
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton.icon(
                          onPressed: _isSubmitting ? null : _submit,
                          icon: const Icon(Icons.arrow_forward_rounded),
                          label: const Padding(
                            padding: EdgeInsets.symmetric(vertical: 14),
                            child: Text('Continue to Dashboard'),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () =>
                              setState(() => _showEmailAuth = !_showEmailAuth),
                          child: Text(
                            _showEmailAuth
                                ? 'Use quick profile entry'
                                : 'Use email login / signup',
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
