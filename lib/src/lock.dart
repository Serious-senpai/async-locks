part of async_locks;

/// Mutex lock to guarantee exclusive access to a shared state.
///
/// A lock object can be in one of the two states: "locked" or "unlocked".
///
/// If the lock is "locked", all futures which call [acquire] will be put in a waiting queue
/// and will proceed in order for each [release] call.
///
/// If the lock is "unlocked", calling [acquire] will set the lock to "locked" state and
/// return immediately.
///
/// See also: [Python documentation](https://docs.python.org/3.9/library/asyncio-sync.html#asyncio.Lock)
class Lock {
  final _waiters = ListQueue<_FutureWaiter>();
  bool _locked = false;

  /// Create a new [Lock] object.
  Lock();

  /// Whether this lock is acquired.
  bool get locked => _locked;

  /// Number of futures which are currently waiting to acquire this lock.
  ///
  /// This is the length of the waiting queue.
  int get waiters => _waiters.length;

  /// Acquire the lock. If the lock has already been acquired then this method will wait
  /// asynchronously until the lock is released.
  ///
  /// When multiple futures are waiting for the lock, they will be put in a queue and only
  /// the first one will proceed when the lock is available.
  Future<void> acquire() async {
    if (!_locked && _waiters.isEmpty) {
      _locked = true;
      return;
    }

    var waiter = _FutureWaiter();
    _waiters.add(waiter);

    await waiter.future;
    return;
  }

  /// Release the lock. If the lock isn't acquired then this method does nothing.
  void release() {
    if (_locked) {
      if (_waiters.isEmpty) {
        _locked = false;
      } else {
        var waiter = _waiters.removeFirst();
        waiter.complete();
      }
    }
  }

  /// Acquire the lock, asynchronously run [func] and release the lock afterwards.
  ///
  /// The returned value is the result of [func]
  Future<T> run<T>(Future<T> Function() func) async {
    await acquire();
    try {
      var result = await func();
      return result;
    } finally {
      release();
    }
  }

  /// Cancel all futures waiting for this [Lock] to be available by throwing a
  /// [LockAcquireFailureException] to them.
  void cancelAll() {
    while (_waiters.isNotEmpty) {
      var waiter = _waiters.removeFirst();
      waiter.completeError(LockAcquireFailureException);
    }
  }
}
