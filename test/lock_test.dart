import "dart:core";

import "package:async_locks/async_locks.dart";
import "package:test/test.dart";

import "utils.dart";

const futures_count = 5;

Future<void> sampleFuture(Lock lock) async {
  await lock.run(() => Future.delayed(waiting));
}

Future<void> lockingCheckFuture(Lock lock) async {
  await Future.delayed(short_waiting);
  expect(lock.locked, isTrue);
}

void main() {
  var locks = <Lock>[Lock(), UnfairLock()];

  for (var lock in locks) {
    test(
      "Testing control flow: $lock",
      () async {
        var futures = <Future<void>>[];
        for (int i = 0; i < futures_count; i++) {
          futures.add(sampleFuture(lock));
        }
        futures.add(lockingCheckFuture(lock));

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
      "Test lock acquire cancellation: $lock",
      () async {
        var futures = <Future<void>>[];
        for (int i = 0; i < futures_count; i++) {
          futures.add(sampleFuture(lock));
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
}
