import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/network/api_exception.dart';
import '../../../core/router/app_redirect.dart';
import '../../../core/theme/app_colors.dart';
import '../application/auth_controller.dart';
import 'auth_validators.dart';
import 'auth_widgets.dart';

class RegisterPage extends ConsumerStatefulWidget {
  const RegisterPage({super.key, this.next});

  final String? next;

  @override
  ConsumerState<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends ConsumerState<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _submitting = false;
  String? _error;

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_submitting) return;
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() {
      _submitting = true;
      _error = null;
    });

    try {
      await ref
          .read(authControllerProvider.notifier)
          .register(
            fullName: _name.text.trim(),
            email: _email.text.trim(),
            password: _password.text,
          );
    } on ApiException catch (error) {
      if (mounted) setState(() => _error = error.message);
    } catch (_) {
      if (mounted) {
        setState(() => _error = 'Something went wrong. Please try again.');
      }
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 56, 16, 24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Center(child: AuthLogo()),
                const SizedBox(height: 48),
                AuthField(
                  controller: _name,
                  hint: 'Full name',
                  icon: Icons.person_outline,
                  keyboardType: TextInputType.name,
                  textInputAction: TextInputAction.next,
                  enabled: !_submitting,
                  validator: validateFullName,
                ),
                const SizedBox(height: 8),
                AuthField(
                  controller: _email,
                  hint: 'Email',
                  icon: Icons.mail_outline,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  enabled: !_submitting,
                  validator: validateEmail,
                  showCheckWhen: isValidEmail,
                ),
                const SizedBox(height: 8),
                AuthField(
                  controller: _password,
                  hint: 'Password',
                  icon: Icons.lock_outline,
                  isPassword: true,
                  textInputAction: TextInputAction.done,
                  enabled: !_submitting,
                  validator: validateNewPassword,
                  onSubmitted: (_) => _submit(),
                ),
                const Padding(
                  padding: EdgeInsets.only(top: 8, left: 12),
                  child: Text(
                    'At least 8 characters, with an uppercase letter, '
                    'a lowercase letter, and a number.',
                    style: TextStyle(fontSize: 12, color: AppColors.muted),
                  ),
                ),
                if (_error != null) AuthErrorText(_error!),
                const SizedBox(height: 32),
                FilledButton(
                  onPressed: _submitting ? null : _submit,
                  child: SubmitLabel(label: 'Sign up', busy: _submitting),
                ),
                const SizedBox(height: 16),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: _submitting
                        ? null
                        : () => context.go(
                            authLocation('/login', next: widget.next),
                          ),
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.brand,
                    ),
                    child: const Text(
                      'Sign in',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
