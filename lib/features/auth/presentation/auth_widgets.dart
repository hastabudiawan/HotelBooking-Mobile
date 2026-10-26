import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

class AuthLogo extends StatelessWidget {
  const AuthLogo({super.key});

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/images/logo_brown.png',
      height: 96,
      // Cadangan kalau berkas logo belum disalin ke assets.
      errorBuilder: (context, error, stackTrace) => Text(
        'PV',
        style: Theme.of(context).textTheme.headlineLarge
            ?.copyWith(color: AppColors.brand, fontWeight: FontWeight.w700),
      ),
    );
  }
}

// Kolom isian bergaya desain: ikon di kiri, garis bawah, dan di kanan
// centang hijau (email valid) atau tombol mata (password).
class AuthField extends StatefulWidget {
  const AuthField({
    super.key,
    required this.controller,
    required this.hint,
    required this.icon,
    this.isPassword = false,
    this.keyboardType,
    this.textInputAction,
    this.validator,
    this.showCheckWhen,
    this.onSubmitted,
    this.enabled = true,
  });

  final TextEditingController controller;
  final String hint;
  final IconData icon;
  final bool isPassword;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final FormFieldValidator<String>? validator;
  final bool Function(String text)? showCheckWhen;
  final ValueChanged<String>? onSubmitted;
  final bool enabled;

  @override
  State<AuthField> createState() => _AuthFieldState();
}

class _AuthFieldState extends State<AuthField> {
  bool _hidden = true;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final iconColor = dark ? Colors.white60 : AppColors.muted;
    final lineColor = dark ? Colors.white24 : AppColors.line;

    return ValueListenableBuilder<TextEditingValue>(
      valueListenable: widget.controller,
      builder: (context, value, _) {
        Widget? suffix;
        if (widget.isPassword) {
          suffix = IconButton(
            tooltip: _hidden ? 'Show password' : 'Hide password',
            icon: Icon(
              _hidden
                  ? Icons.visibility_off_outlined
                  : Icons.visibility_outlined,
              color: iconColor,
            ),
            onPressed: () => setState(() => _hidden = !_hidden),
          );
        } else if (widget.showCheckWhen?.call(value.text) ?? false) {
          suffix = const Icon(
            Icons.check_circle,
            color: AppColors.success,
            size: 20,
          );
        }

        return TextFormField(
          controller: widget.controller,
          enabled: widget.enabled,
          obscureText: widget.isPassword && _hidden,
          keyboardType: widget.keyboardType,
          textInputAction: widget.textInputAction,
          validator: widget.validator,
          onFieldSubmitted: widget.onSubmitted,
          decoration: InputDecoration(
            hintText: widget.hint,
            prefixIcon: Icon(widget.icon, color: iconColor),
            suffixIcon: suffix,
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: lineColor),
            ),
            disabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: lineColor),
            ),
            focusedBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: AppColors.brand, width: 1.5),
            ),
          ),
        );
      },
    );
  }
}

// Pesan error dari backend (misalnya "Email atau password salah.").
class AuthErrorText extends StatelessWidget {
  const AuthErrorText(this.message, {super.key});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Text(
        message,
        textAlign: TextAlign.center,
        style: const TextStyle(color: AppColors.danger, fontSize: 14),
      ),
    );
  }
}

// Isi tombol utama: teks, atau lingkaran berputar saat sedang mengirim.
class SubmitLabel extends StatelessWidget {
  const SubmitLabel({super.key, required this.label, required this.busy});

  final String label;
  final bool busy;

  @override
  Widget build(BuildContext context) {
    if (!busy) return Text(label);
    return const SizedBox(
      height: 20,
      width: 20,
      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
    );
  }
}
