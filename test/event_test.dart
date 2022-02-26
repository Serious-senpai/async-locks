import "package:async_locks/async_locks.dart";

class Program {
  final event = Event();
  final data = <int>[];

  Future<void> mainFuture() async {
    for (int i = 0; i < 100; i++) {
      data.add(i);
    }
    event.set();
  }

  Future<void> runFuture() async {
    await event.wait();
    for (int i = 0; i < 10; i++) {
      data.add(-1);
    }
  }

  Future<void> run() async {
    await Future.wait([mainFuture(), runFuture(), runFuture(), runFuture(), runFuture()]);
  }
}

bool checkResult(List<int> data) {
  for (int i = 0; i < 99; i++) {
    if (data[i] > data[i + 1]) return false;
  }
  for (int i = 100; i < 140; i++) {
    if (data[i] != -1) return false;
  }
  return true;
}

void main() async {
  var program = Program();
  await program.run();
  print(checkResult(program.data) ? "Test succeeded" : "Test failed");
}
