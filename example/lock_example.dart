import "package:async_locks/async_locks.dart";

class Program {
  final lock = Lock();

  Future<void> runFuture(int n) async {
    print("Starting Future-$n");
    await lock.acquire();
    print("Future-$n acquired the lock");
    await Future.delayed(const Duration(seconds: 2));
    print("Future-$n has slept for 2 seconds");
    lock.release();
  }

  Future<void> run() async {
    print("Running program");
    await Future.wait([runFuture(1), runFuture(2), runFuture(3), runFuture(4)]);
    print("Finished!");
  }
}

void main() async {
  var program = Program();
  await program.run();
}
