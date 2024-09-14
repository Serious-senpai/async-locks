import "dart:core";

import "package:async_locks/async_locks.dart";
import "package:test/test.dart";

import "utils.dart";

const futures_count = 20;
const concurrency = 4;

void main() {
  final semaphores = [Semaphore(concurrency), BoundedSemaphore(concurrency)];
  for (final semaphore in semaphores) {
    test(
      "Control flow test: $semaphore",
      () async {
        final futures = <Future<void>>[];
        for (int i = 0; i < futures_count; i++) {
          futures.add(semaphore.run(() => Future.delayed(waiting)));
        }

        final timer = Stopwatch();
        timer.start();
        await Future.wait(futures);
        timer.stop();

        expect(semaphore.locked, isFalse);
        expect(timer.elapsedMilliseconds, approximates(1000 * (futures_count / concurrency).ceil(), 100));
        print("Elapsed time: ${timer.elapsedMilliseconds} ms");
      },
    );

    test(
      "Semaphore acquire cancellation test: $semaphore",
      () async {
        final futures = <Future<void>>[];
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
    "BoundedSemaphore release limit test",
    () async {
      final boundedSemaphore = BoundedSemaphore(concurrency);
      expect(boundedSemaphore.release, throwsA(isA<BoundedSemaphoreLimitException>()));

      final boundedSemaphoreNoError = BoundedSemaphore(concurrency, error: false);
      expect(boundedSemaphoreNoError.release, isNot(throwsA(isA<BoundedSemaphoreLimitException>())));
    },
  );
}
