import "dart:core";

import "package:async_locks/async_locks.dart";
import "package:test/test.dart";

import "utils.dart";

const futures_count = 5;

final lock = Lock();
final waiting = const Duration(seconds: 1);

Future<void> sampleFuture() async {
  await lock.run(() => Future.delayed(waiting));
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

      expect(timer.elapsedMilliseconds, approximates(1000 * futures_count, 100));
    },
  );
}
