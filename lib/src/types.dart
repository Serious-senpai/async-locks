part of async_locks;

typedef _FutureWaiter = Completer<void>;

class AsyncLocksException implements Exception {}

class EventCancelledException extends AsyncLocksException {}

class LockAcquireFailureException extends AsyncLocksException {}

class SemaphoreAcquireFailureException extends AsyncLocksException {}
