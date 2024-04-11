/// Provides a suite of synchronization primitives designed to streamline the coordination of
/// asynchronous operations in Dart applications. Inspired by Python's established concurrency
/// features, this package offers a familiar and intuitive approach to managing shared resources
/// and preventing race conditions in asynchronous code.
///
/// See also:
/// - [Python documentation](https://docs.python.org/3/library/asyncio-sync.html)
library async_locks;

import "dart:async";
import "dart:collection";

part "src/event.dart";
part "src/lock.dart";
part "src/semaphore.dart";
part "src/types.dart";
