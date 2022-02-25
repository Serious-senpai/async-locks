import "package:async_locks/locks.dart";

class Program {
  final event = Event();

  Future<void> mainFuture() async {
    print("Running mainFuture");
    await Future.delayed(const Duration(seconds: 3));
    print("Completing mainFuture");
    event.set();
  }

  Future<void> runFuture(int n) async {
    print("Started Future-$n. Waiting for mainFuture to complete");
    await event.wait();
    print("Future-$n completed");
  }

  Future<void> run() async {
    print("Running program");
    await Future.wait([mainFuture(), runFuture(1), runFuture(2), runFuture(3), runFuture(4)]);
    print("Finished!");
  }
}

void main() async {
  var program = Program();
  await program.run();
}
