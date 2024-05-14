# async-locks

[![Package Test](https://github.com/Serious-senpai/async-locks/actions/workflows/tests.yml/badge.svg)](https://github.com/Serious-senpai/async-locks/actions/workflows/tests.yml)
[![Documentation Build](https://github.com/Serious-senpai/async-locks/actions/workflows/build-docs.yml/badge.svg)](https://github.com/Serious-senpai/async-locks/actions/workflows/build-docs.yml)

**Effortlessly synchronize asynchronous operations in your Dart applications**

This package provides a set of intuitive primitives inspired by Python's established concurrency features, making it easy to manage shared resources and prevent race conditions in asynchronous code. 

**Key features:**

* Familiar concepts: `Lock`, `Event`, and `Semaphore` for a smooth transition from Python's concurrency model.
* Optimized for Dart: Efficient implementation tailored for Dart's asynchronous programming capabilities.
* Clear and concise documentation: Quickly understand how to use each primitive effectively.

**Installation:**

Add `async_locks` as a dependency in your `pubspec.yaml` file:

```yaml
dependencies:
  async_locks: ^latest_version
```

**Sample usage:**

```dart
import "dart:io";
import "package:async_locks/async_locks.dart";

final lock = Lock();

Future<void> randomAsyncFunction() async {
  final result = await lock.run(() async => await accessSharedState());
}
```

**Synchronization primitives:**

* **`Lock`:** A mutex lock that guarantees exclusive access to a shared state, preventing race conditions.
* **`Event`:** An object used to notify multiple futures that a specific event has occurred.
* **`Semaphore`:** A synchronization primitive that allows a limited number of futures to acquire it concurrently.

**Inspired by Python's `asyncio`:**

While the implementation details differ, `async_locks` offers a familiar approach for developers coming from a Python background. See the Python documentation for reference: https://docs.python.org/3/library/asyncio-sync.html
