import "dart:io";

import "package:async_locks/async_locks.dart";
import "package:test/test.dart";

const String filename = "example.test";
const int futures_count = 100;
late final Matcher matcher;

class Program {
  final lock = Lock();

  Future<void> runWithLock(int value) async {
    var file = File(filename);
    await lock.run(() async => await file.writeAsString("Writing from Future-$value\n", mode: FileMode.append, flush: true));
  }

  Future<void> runWithoutLock(int value) async {
    var file = File(filename);
    await file.writeAsString("Writing from Future-$value\n", mode: FileMode.append, flush: true);
  }

  Future<void> runWithLockInvoker() async {
    var futures = <Future<void>>[];
    for (int value = 0; value < futures_count; value++) {
      futures.add(runWithLock(value));
    }

    await Future.wait(futures, eagerError: true);

    expect(await File(filename).readAsString(), matcher);
  }

  Future<void> runWithoutLockInvoker() async {
    var futures = <Future<void>>[];
    for (int value = 0; value < futures_count; value++) {
      futures.add(runWithoutLock(value));
    }

    await Future.wait(futures, eagerError: true);

    expect(await File(filename).readAsString(), isNot(matcher));
  }
}

void main() async {
  var expected_content = "";
  for (int value = 0; value < futures_count; value++) {
    expected_content += "Writing from Future-$value\n";
  }
  matcher = equals(expected_content);

  var file = File(filename);
  if (await file.exists()) {
    await file.delete();
  }

  var program = Program();

  test(
    "Concurrent write to a file with a lock",
    program.runWithLockInvoker,
  );

  test(
    "Concurrent write to a file without a lock",
    program.runWithoutLockInvoker,
  );
}
