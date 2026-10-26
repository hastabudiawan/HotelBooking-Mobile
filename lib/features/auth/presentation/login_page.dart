import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/network/api_exception.dart';
import '../../../core/router/app_redirect.dart';
import '../../../core/theme/app_colors.dart';
import '../application/auth_controller.dart';
import 'auth_validators.dart';
import 'auth_widgets.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key, this.next});

  // Tujuan setelah masuk (dari ?next=).
  final String? next;

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _submitting = false;
  String? _error;

  @override
  void dispose() {
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
      // Berhasil: status login berubah dan router mengalihkan sendiri.
      await ref
          .read(authControllerProvider.notifier)
          .login(email: _email.text.trim(), password: _password.text);
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
                const SizedBox(height: 56),
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
                  validator: validatePasswordPresent,
                  onSubmitted: (_) => _submit(),
                ),
                if (_error != null) AuthErrorText(_error!),
                const SizedBox(height: 32),
                FilledButton(
                  onPressed: _submitting ? null : _submit,
                  child: SubmitLabel(label: 'Sign in', busy: _submitting),
                ),
                const SizedBox(height: 16),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: _submitting
                        ? null
                        : () => context.go(
                            authLocation('/register', next: widget.next),
                          ),
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.brand,
                    ),
                    child: const Text(
                      'Register now',
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
