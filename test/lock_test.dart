import "package:async_locks/async_locks.dart";

class Program {
  final lock = Lock();
  final data = <int>[];

  Future<void> runFuture(int n) async {
    await lock.run(() async {
      for (int i = n * 100; i < n + 100; i++) {
        data.add(i);
        await Future.delayed(const Duration(seconds: 0));
      }
    });
  }

  Future<void> run() async {
    await Future.wait([runFuture(1), runFuture(2), runFuture(3), runFuture(4)]);
  }
}

bool incrementList(List<int> data) {
  for (int i = 0; i < data.length - 2; i++) {
    if (data[i] > data[i + 1]) return false;
  }
  return true;
}

void main() async {
  var program = Program();
  await program.run();
  print(incrementList(program.data) ? "Test succeeded" : "Test failed");
}
