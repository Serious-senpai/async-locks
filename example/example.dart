/// Synchronization to avoid concurrent write to a file
import "dart:io";

import "package:async_locks/async_locks.dart";

class Program {
  final lock = Lock();

  Future<void> runFuture(int n) async {
    var file = File("example.test");
    await lock.run(() async => await file.writeAsString("Writing from Future-$n\n", mode: FileMode.append, flush: true));
  }

  Future<void> run() async {
    await Future.wait([runFuture(1), runFuture(2), runFuture(3), runFuture(4)]);
    var file = File("example.test");
    var content = await file.readAsString();
    print(content);
  }
}

void main() async {
  // Create example file
  var file = File("example.test");
  await file.writeAsString("EXAMPLE FILE\n");

  var program = Program();
  await program.run();
}
