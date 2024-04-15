part of "../async_locks.dart";

typedef _FutureWaiter = Completer<void>;

/// Base class for all exceptions from this package
class AsyncLocksException implements Exception {}

/// Exception thrown to futures cancelled by [Event.cancelAll]
class EventCancelledException extends AsyncLocksException {}

/// Exception thrown to futures cancelled by [Lock.cancelAll] or [UnfairLock.cancelAll]
class LockAcquireFailureException extends AsyncLocksException {}

/// Exception thrown to futures cancelled by [Semaphore.cancelAll] or [UnfairSemaphore.cancelAll]
class SemaphoreAcquireFailureException extends AsyncLocksException {}

/// Exception that may be thrown in [BoundedSemaphore.release]
class BoundedSemaphoreLimitException extends AsyncLocksException {}
