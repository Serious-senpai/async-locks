import "dart:core";

import "package:async_locks/async_locks.dart";
import "package:test/test.dart";

import "utils.dart";

const futures_count = 20;
const concurrency = 4;

Future<void> sampleFuture(Semaphore semaphore) async {
  await semaphore.run(() => Future.delayed(waiting));
}

void main() {
  var semaphores = <Semaphore>[Semaphore(concurrency), UnfairSemaphore(concurrency)];

  for (var semaphore in semaphores) {
    test(
      "Testing control flow: $semaphore",
      () async {
        var futures = <Future<void>>[];
        for (int i = 0; i < futures_count; i++) {
          futures.add(sampleFuture(semaphore));
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
      "Test semaphore acquire cancellation: $semaphore",
      () async {
        var futures = <Future<void>>[];
        for (int i = 0; i < futures_count; i++) {
          futures.add(sampleFuture(semaphore));
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
}
