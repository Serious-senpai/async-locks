import "package:async_locks/locks.dart";

class Program {
  final lock = Lock();
  final data = <int>[];

  Future<void> runFuture(int n) async {
    await lock.acquire();
    for (int i = n * 100; i < n + 100; i++) {
      data.add(i);
    }
    lock.release();
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
