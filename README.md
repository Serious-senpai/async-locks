## async-locks
Synchronization primitives for asynchronous Dart code, inspired from Python
### Usage
#### With `Lock`
- Can be used to guarantee exclusive access to a shared resource.
```dart
var lock = Lock();
await lock.acquire();
// access the shared resource here
// ...
lock.release();
```
- Starting from v1.1.0, you can use the `lock.run` method.
```dart
var lock = Lock();
var result = await lock.run(() async {
  // access shared resource
  // ...
});
```
#### With `Event`
- Can be used to notify multiple futures that an event has occured.
```dart
import "package:async_locks/async_locks.dart";

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
```
In this example, each `runFuture` waits for the event to be set in `mainFuture`.

Both `Lock` and `Event` are *fair*: the first proceeding future will be the future that called `await lock.acquire()` or `await event.wait()` first (though this is usually less important when using `Event` as all futures will be awaken anyway).
