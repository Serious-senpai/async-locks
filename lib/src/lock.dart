part of "../async_locks.dart";

/// Mutex lock to guarantee exclusive access to a shared state.
///
/// A [Lock] object can be in one of two states: "locked" or "unlocked".
///
/// If the lock is "locked", all futures that call [acquire] will be put in a waiting FIFO queue
/// and will proceed in order for each [release] call.
///
/// If the lock is "unlocked", calling [acquire] will set the lock to the "locked" state and
/// return immediately.
///
/// Example usage:
/// ```dart
/// final lock = Lock();
///
/// // Acquire the lock
/// await lock.acquire();
///
/// try {
///   // Perform exclusive operations on the shared state
///   // ...
/// } finally {
///   // Release the lock
///   lock.release();
/// }
/// ```
///
/// See also: [Python documentation](https://docs.python.org/3/library/asyncio-sync.html#asyncio.Lock)
class Lock extends _Acquirable {
  final _waiters = ListQueue<_FutureWaiter>();
  bool _locked = false;

  /// Construct a new [Lock] object (initially unlocked).
  Lock();

  /// Whether this lock is acquired.
  bool get locked => _locked;

  /// Number of futures which are currently waiting to acquire this lock.
  ///
  /// This is the length of the waiting queue.
  int get waiters => _waiters.length;

  /// Acquire the lock. If the lock has already been acquired then this method will wait
  /// asynchronously until the lock is released.
  @override
  Future<void> acquire() async {
    if (!_locked && _waiters.isEmpty) {
      _locked = true;
      return;
    }

    var waiter = _FutureWaiter();
    _waiters.add(waiter);

    return waiter.future;
  }

  /// Release the lock. If the lock isn't acquired then this method does nothing.
  @override
  void release() {
    if (_locked) {
      if (_waiters.isEmpty) {
        _locked = false;
      } else {
        var waiter = _getNextWaiter();
        waiter.complete();
      }
    }
  }

  _FutureWaiter _getNextWaiter() => _waiters.removeFirst();

  /// Acquire the lock, asynchronously run [func] and release the lock afterwards.
  ///
  /// The returned value is the result of [func]
  @override
  Future<T> run<T>(Future<T> Function() func) {
    return super.run(func);
  }

  /// Cancel all futures waiting for this lock to be available by throwing a
  /// [LockAcquireFailureException] to them.
  void cancelAll() {
    while (_waiters.isNotEmpty) {
      var waiter = _waiters.removeFirst();
      waiter.completeError(LockAcquireFailureException());
    }
  }
}
