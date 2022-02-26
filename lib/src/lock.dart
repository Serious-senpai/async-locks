part of async_locks;

/// Documentation at https://docs.python.org/3.9/library/asyncio-sync.html#asyncio.Lock
class Lock {
  final List<_FutureWaiter> _waiters = [];
  bool _locked = false;

  /// Whether this lock is acquired
  bool locked() => _locked;

  /// Acquire the lock. If the lock has already been acquired then this method will block
  /// asynchronously until the lock is released.
  ///
  /// Always return true.
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
    var result = await func();
    release();
    return result;
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
