import "package:async_locks/async_locks.dart";
import "package:test/test.dart";

const futures_count = 100;
final event = Event();

final processing_order = <int>[];

Future<void> append(int value) async {
  if (value > 0) {
    await event.wait();
  }

  processing_order.add(value);
  if (value == 0) {
    event.set();
  }
}

void main() async {
  test(
    "Testing control flow",
    () async {
      var futures = <Future<void>>[];
      for (int value = futures_count - 1; value >= 0; value--) {
        futures.add(append(value));
      }

      await Future.wait(futures);

      expect(processing_order.first, equals(0));
      expect(processing_order.length, equals(futures_count));
    },
  );
}
