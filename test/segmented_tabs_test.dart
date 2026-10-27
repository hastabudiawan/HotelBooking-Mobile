import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:paradise_view/features/bookings/presentation/widgets/segmented_tabs.dart';

void main() {
  testWidgets('SegmentedTabs memanggil onChanged dengan indeks yang diketuk', (
    tester,
  ) async {
    var selected = 0;

    await tester.pumpWidget(
      MaterialApp(
        home: StatefulBuilder(
          builder: (context, setState) => Scaffold(
            body: SegmentedTabs(
              labels: const ['Active', 'Past'],
              selected: selected,
              onChanged: (index) => setState(() => selected = index),
            ),
          ),
        ),
      ),
    );

    expect(selected, 0);

    await tester.tap(find.text('Past'));
    await tester.pumpAndSettle();

    expect(selected, 1);
  });
}
