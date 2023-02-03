import "dart:core";

import "package:async_locks/async_locks.dart";
import "package:test/test.dart";

import "utils.dart";

const futures_count = 5;

final lock = Lock();

Future<void> sampleFuture() async {
  await lock.run(() => Future.delayed(waiting));
}

Future<void> lockingCheckFuture() async {
  await Future.delayed(short_waiting);
  expect(lock.locked, isTrue);
}

void main() {
  test(
    "Testing control flow",
    () async {
      var futures = <Future<void>>[];
      for (int i = 0; i < futures_count; i++) {
        futures.add(sampleFuture());
      }
      futures.add(lockingCheckFuture());

      var timer = Stopwatch();
      timer.start();
      await Future.wait(futures);
      timer.stop();

      expect(lock.locked, isFalse);
      expect(timer.elapsedMilliseconds, approximates(1000 * futures_count, 100));
      print("Elapsed time: ${timer.elapsedMilliseconds} ms");
    },
  );

  test(
    "Test lock acquire cancellation",
    () async {
      var futures = <Future<void>>[];
      for (int i = 0; i < futures_count; i++) {
        futures.add(sampleFuture());
      }

      expect(
        () async {
          lock.cancelAll();
          await Future.wait(futures);
        },
        throwsA(LockAcquireFailureException),
      );
    },
  );
}
