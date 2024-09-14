/// Synchronization to avoid concurrent write to a file
import "dart:io";

import "package:async_locks/async_locks.dart";

class Program {
  final lock = Lock();
  final file = File("example.test");

  Future<void> runFuture(int n) async {
    // Concurrent write (in append mode) to the example file.
    // Race conditions can occur without synchronization. Try removing the lock and see what happens.
    await lock.run(() async => await file.writeAsString("Writing from Future-$n\n", mode: FileMode.append, flush: true));
  }

  Future<void> run() async {
    // Wait for 4 futures
    await Future.wait([runFuture(1), runFuture(2), runFuture(3), runFuture(4)]);

    // Read and print file content to stdout
    final content = await file.readAsString();
    print(content);
  }
}

void main() async {
  final program = Program();

  // Write header to example file
  await program.file.writeAsString("EXAMPLE FILE\n");

  // Run futures with potential race conditions
  await program.run();
}
