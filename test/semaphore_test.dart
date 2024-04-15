import "dart:core";

import "package:async_locks/async_locks.dart";
import "package:test/test.dart";

import "utils.dart";

const futures_count = 20;
const concurrency = 4;

void main() {
  var semaphores = [Semaphore(concurrency), BoundedSemaphore(concurrency), UnfairSemaphore(concurrency)];
  for (var semaphore in semaphores) {
    test(
      "Testing control flow: $semaphore",
      () async {
        var futures = <Future<void>>[];
        for (int i = 0; i < futures_count; i++) {
          futures.add(semaphore.run(() => Future.delayed(waiting)));
        }

        var timer = Stopwatch();
        timer.start();
        await Future.wait(futures);
        timer.stop();

        expect(semaphore.locked, isFalse);
        expect(timer.elapsedMilliseconds, approximates(1000 * (futures_count / concurrency).ceil(), 100));
        print("Elapsed time: ${timer.elapsedMilliseconds} ms");
      },
    );

    test(
      "Test semaphore acquire cancellation: $semaphore",
      () async {
        var futures = <Future<void>>[];
        for (int i = 0; i < futures_count; i++) {
          futures.add(semaphore.run(() => Future.delayed(waiting)));
        }

        expect(
          () async {
            semaphore.cancelAll();
            await Future.wait(futures);
          },
          throwsException,
        );
      },
    );
  }

  test(
    "BoundedSemaphore release limit",
    () async {
      var boundedSemaphore = BoundedSemaphore(concurrency);
      expect(boundedSemaphore.release, throwsA(isA<BoundedSemaphoreLimitException>()));
    },
  );
}
