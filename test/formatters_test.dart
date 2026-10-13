import 'package:flutter_test/flutter_test.dart';
import 'package:sam_gig/core/utils/formatters.dart';

void main() {
  test('formatCount abbreviates thousands and millions', () {
    expect(formatCount(999), '999');
    expect(formatCount(1000), '1K');
    expect(formatCount(1500), '1.5K');
    expect(formatCount(2500000), '2.5M');
  });

  test('capitalize handles empty and normal strings', () {
    expect(capitalize(''), '');
    expect(capitalize('nature'), 'Nature');
  });
}
