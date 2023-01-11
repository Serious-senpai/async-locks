import "package:test/test.dart";

final waiting = const Duration(seconds: 1);
final short_waiting = const Duration(milliseconds: 500);

Matcher approximates(num expected, num max_difference) {
  assert(max_difference >= 0);
  return inInclusiveRange(expected - max_difference, expected + max_difference);
}
