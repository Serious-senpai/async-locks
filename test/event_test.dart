import "dart:core";

import "package:async_locks/async_locks.dart";
import "package:test/test.dart";

import "utils.dart";

const futures_count = 5;

final event = Event();

Future<void> sampleFuture() async {
  await event.wait();
  await Future.delayed(waiting);
}

Future<void> mainFuture() async {
  await Future.delayed(waiting);
  expect(event.isSet, isFalse);
  event.set();
}

void main() {
  test(
    "Control flow test: $event",
    () async {
      final futures = <Future<void>>[];
      for (int i = 0; i < futures_count; i++) {
        futures.add(sampleFuture());
      }
      futures.add(mainFuture());

      final timer = Stopwatch();
      timer.start();
      await Future.wait(futures);
      timer.stop();

      expect(event.isSet, isTrue);
      expect(timer.elapsedMilliseconds, approximates(1000 * 2, 100));
      print("Elapsed time: ${timer.elapsedMilliseconds} ms");
    },
  );

  test(
    "Event waiting cancellation test: $event",
    () async {
      event.clear();

      final futures = <Future<void>>[];
      for (int i = 0; i < futures_count; i++) {
        futures.add(sampleFuture());
      }

      expect(
        () async {
          event.cancelAll();
          await Future.wait(futures);
        },
        throwsException,
      );
    },
  );
}
