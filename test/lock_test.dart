import "dart:core";

import "package:async_locks/async_locks.dart";
import "package:test/test.dart";

import "utils.dart";

const futures_count = 5;

void main() {
  final lock = Lock();

  test(
    "Control flow test: $lock",
    () async {
      final futures = <Future<void>>[];
      for (int i = 0; i < futures_count; i++) {
        futures.add(lock.run(() => Future.delayed(waiting)));
      }
      futures.add(Future.delayed(short_waiting));

      final timer = Stopwatch();
      timer.start();
      await Future.wait(futures);
      timer.stop();

      expect(lock.locked, isFalse);
      expect(timer.elapsedMilliseconds, approximates(1000 * futures_count, 100));
      print("Elapsed time: ${timer.elapsedMilliseconds} ms");
    },
  );

  test(
    "Lock acquisition cancellation test: $lock",
    () async {
      final futures = <Future<void>>[];
      for (int i = 0; i < futures_count; i++) {
        futures.add(lock.run(() => Future.delayed(waiting)));
      }

      expect(
        () async {
          lock.cancelAll();
          await Future.wait(futures);
        },
        throwsException,
      );
    },
  );
}
