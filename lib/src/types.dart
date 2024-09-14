part of "../async_locks.dart";

typedef _FutureWaiter = Completer<void>;

abstract class _Acquirable {
  Future<void> acquire();
  void release();

  Future<T> run<T>(Future<T> Function() func) async {
    await acquire();
    try {
      final result = await func();
      return result;
    } finally {
      release();
    }
  }
}

/// Base class for all exceptions from this package
class AsyncLocksException implements Exception {}

/// Exception thrown to futures cancelled by [Event.cancelAll]
class EventCancelledException extends AsyncLocksException {}

/// Exception thrown to futures cancelled by [Lock.cancelAll]
class LockAcquireFailureException extends AsyncLocksException {}

/// Exception thrown to futures cancelled by [BoundedSemaphore.cancelAll] or [Semaphore.cancelAll]
class SemaphoreAcquireFailureException extends AsyncLocksException {}

/// Exception that may be thrown in [BoundedSemaphore.release]
class BoundedSemaphoreLimitException extends AsyncLocksException {}
