import 'dart:async';

import 'package:flutter/material.dart';

import '../../domain/booking_rules.dart';

class Countdown extends StatefulWidget {
  const Countdown({
    super.key,
    required this.expiresAt,
    required this.onExpired,
  });

  final DateTime expiresAt;
  final VoidCallback onExpired;

  @override
  State<Countdown> createState() => _CountdownState();
}

class _CountdownState extends State<Countdown> {
  Timer? _timer;
  late Duration _remaining;
  bool _fired = false;

  void _update() {
    _remaining = widget.expiresAt.difference(DateTime.now().toUtc());
    if (_remaining > Duration.zero) return;

    _timer?.cancel();
    if (_fired) return;
    _fired = true;
    // Dipanggil setelah frame selesai, supaya aman mengubah state induknya.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) widget.onExpired();
    });
  }

  @override
  void initState() {
    super.initState();
    _update();
    if (_remaining > Duration.zero) {
      _timer = Timer.periodic(const Duration(seconds: 1), (_) {
        if (mounted) setState(_update);
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      formatCountdown(_remaining),
      style: const TextStyle(fontWeight: FontWeight.w700),
    );
  }
}
