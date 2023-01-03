import "dart:io";

import "package:async_locks/async_locks.dart";
import "package:test/test.dart";

const String filename = "example.test";
const int futures_count = 10;
late final Matcher matcher;

class Program {
  final lock = Lock();

  Future<void> runWithLock(int n) async {
    var file = File(filename);
    await lock.run(() async => await file.writeAsString("Writing from Future-$n\n", mode: FileMode.append, flush: true));
  }

  Future<void> runWithoutLock(int n) async {
    var file = File(filename);
    await file.writeAsString("Writing from Future-$n\n", mode: FileMode.append, flush: true);
  }

  Future<void> runWithLockInvoker() async {
    var futures = <Future>[];
    for (int _t = 0; _t < futures_count; _t++) {
      futures.add(runWithLock(_t));
    }

    await Future.wait(futures, eagerError: true);

    expect(await File(filename).readAsString(), matcher);
  }

  Future<void> runWithoutLockInvoker() async {
    var futures = <Future>[];
    for (int _t = 0; _t < futures_count; _t++) {
      futures.add(runWithoutLock(_t));
    }

    await Future.wait(futures, eagerError: true);

    expect(await File(filename).readAsString(), isNot(matcher));
  }
}

void main() async {
  var expected_content = "";
  for (int _t = 0; _t < futures_count; _t++) {
    expected_content += "Writing from Future-$_t\n";
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
