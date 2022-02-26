part of async_locks;

/// Mutex lock to guarantee exclusive access to a shared state.
///
/// See [Python documentation](https://docs.python.org/3.9/library/asyncio-sync.html#asyncio.Lock)
class Lock {
  final List<_FutureWaiter> _waiters = [];
  bool _locked = false;

  /// Create a new [Lock] object.
  Lock();

  /// Whether this lock is acquired
  bool locked() => _locked;

  /// Acquire the lock. If the lock has already been acquired then this method will wait
  /// asynchronously until the lock is released.
  ///
  /// When multiple futures are waiting for the lock, only the first one proceeds when
  /// the lock is available.
  ///
  /// This method always returns `true`.
  Future<bool> acquire() async {
    if (!_locked && _waiters.isEmpty) {
      _locked = true;
      return true;
    }

    var waiter = _FutureWaiter();
    _waiters.add(waiter);

    try {
      await waiter.future;
    } finally {
      _waiters.remove(waiter);
    }

    _locked = true;
    return true;
  }

  /// Release the lock. If the lock isn't acquired then this method does nothing.
  void release() {
    if (_locked) {
      _locked = false;
      _wakeUpFirst();
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

  void _wakeUpFirst() {
    if (_waiters.isEmpty) return;

    for (int i = 0; i < _waiters.length; i++) {
      var waiter = _waiters[i];
      if (!waiter.isCompleted) {
        waiter.complete();
        return;
      }
    }
  }
}
