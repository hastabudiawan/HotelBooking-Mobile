import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/format.dart';
import '../../data/booking_models.dart';
import 'booking_form_widgets.dart';

class PayForm extends StatefulWidget {
  const PayForm({
    super.key,
    required this.amount,
    required this.busy,
    required this.onPay,
    this.error,
  });

  final int amount;
  final bool busy;
  final String? error;
  final void Function(PaymentMethod method, bool simulateFailure) onPay;

  @override
  State<PayForm> createState() => _PayFormState();
}

class _PayFormState extends State<PayForm> {
  PaymentMethod _method = PaymentMethod.transfer;
  bool _simulateFailure = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('Payment method', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 12),
        for (final method in PaymentMethod.values)
          _MethodTile(
            label: method.label,
            selected: method == _method,
            enabled: !widget.busy,
            onTap: () => setState(() => _method = method),
          ),
        const SizedBox(height: 4),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          dense: true,
          value: _simulateFailure,
          onChanged: widget.busy
              ? null
              : (value) => setState(() => _simulateFailure = value),
          title: Text(
            'Demo only: simulate a declined payment',
            style: TextStyle(fontSize: 12, color: mutedColor(context)),
          ),
        ),
        if (widget.error != null)
          Padding(
            padding: const EdgeInsets.only(top: 8, bottom: 8),
            child: Text(
              widget.error!,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.danger),
            ),
          ),
        const SizedBox(height: 8),
        FilledButton(
          onPressed: widget.busy
              ? null
              : () => widget.onPay(_method, _simulateFailure),
          child: widget.busy
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : Text('Pay ${formatRupiah(widget.amount)}'),
        ),
        const SizedBox(height: 8),
        Text(
          'This is a simulated payment. No real money is charged.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 12, color: mutedColor(context)),
        ),
      ],
    );
  }
}

class _MethodTile extends StatelessWidget {
  const _MethodTile({
    required this.label,
    required this.selected,
    required this.enabled,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: selected
            ? (dark ? AppColors.darkSurface : AppColors.brandSoft)
            : Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: BorderSide(
            color: selected
                ? AppColors.brand
                : (dark ? Colors.white24 : AppColors.line),
          ),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: enabled ? onTap : null,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            child: Row(
              children: [
                Icon(
                  selected
                      ? Icons.radio_button_checked
                      : Icons.radio_button_unchecked,
                  size: 20,
                  color: selected ? AppColors.brand : mutedColor(context),
                ),
                const SizedBox(width: 12),
                Text(label),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
