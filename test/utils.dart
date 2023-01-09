import "package:test/test.dart";

Matcher approximates(num expected, num max_difference) {
  assert(max_difference >= 0);
  return inExclusiveRange(expected - max_difference, expected + max_difference);
}
