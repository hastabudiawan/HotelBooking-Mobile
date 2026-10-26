import 'package:flutter_test/flutter_test.dart';
import 'package:paradise_view/core/utils/format.dart';

void main() {
  test('plural memakai bentuk tunggal hanya untuk 1', () {
    expect(plural(1, 'guest'), '1 guest');
    expect(plural(2, 'guest'), '2 guests');
    expect(plural(0, 'night'), '0 nights');
    expect(plural(3, 'child', 'children'), '3 children');
    expect(plural(1, 'child', 'children'), '1 child');
  });

  test('formatRupiah memakai pemisah titik dan tanpa desimal', () {
    // Spasi setelah "Rp" bisa berupa spasi biasa atau spasi tanpa putus.
    final text = formatRupiah(1300000).replaceAll(' ', ' ');
    expect(text, 'Rp 1.300.000');
  });
}
