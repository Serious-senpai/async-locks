import "dart:core";

import "package:async_locks/async_locks.dart";
import "package:test/test.dart";

import "utils.dart";

const futures_count = 20;
const concurrency = 4;

final semaphore = Semaphore(concurrency);

Future<void> sampleFuture() async {
  await semaphore.run(() => Future.delayed(waiting));
}

void main() {
  test(
    "Testing control flow",
    () async {
      var futures = <Future<void>>[];
      for (int i = 0; i < futures_count; i++) {
        futures.add(sampleFuture());
      }

      var timer = Stopwatch();
      timer.start();
      await Future.wait(futures);
      timer.stop();

      expect(semaphore.locked, isFalse);
      expect(timer.elapsedMilliseconds, approximates(1000 * futures_count / concurrency, 100));
      print("Elapsed time: ${timer.elapsedMilliseconds} ms");
    },
  );

  test(
    "Test semaphore acquire cancellation",
    () async {
      var futures = <Future<void>>[];
      for (int i = 0; i < futures_count; i++) {
        futures.add(sampleFuture());
      }

      expect(
        () async {
          semaphore.cancelAll();
          await Future.wait(futures);
        },
        throwsA(SemaphoreAcquireFailureException),
      );
    },
  );
}
