part of async_locks;

typedef _FutureWaiter = Completer<void>;

/// Base class for all exceptions from this package
class AsyncLocksException implements Exception {}

/// Exception thrown to futures cancelled by [Event.cancelAll]
class EventCancelledException extends AsyncLocksException {}

/// Exception thrown to futures cancelled by [Lock.cancelAll]
class LockAcquireFailureException extends AsyncLocksException {}

/// Exception thrown to futures cancelled by [Semaphore.cancelAll]
class SemaphoreAcquireFailureException extends AsyncLocksException {}
