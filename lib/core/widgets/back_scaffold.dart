import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class BackScaffold extends StatelessWidget {
  const BackScaffold({
    super.key,
    required this.child,
    required this.fallbackLocation,
    this.title,
  });

  final Widget child;
  final String? title;

  // Tujuan kalau tidak ada halaman sebelumnya untuk dikembalikan.
  final String fallbackLocation;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: title == null ? null : Text(title!),
        leading: IconButton(
          tooltip: 'Back',
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go(fallbackLocation);
            }
          },
        ),
      ),
      body: child,
    );
  }
}
