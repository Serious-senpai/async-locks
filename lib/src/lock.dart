part of locks;

/// Documentation at https://docs.python.org/3.9/library/asyncio-sync.html#asyncio.Lock
class Lock {
  final List<FutureWaiter> _waiters = [];
  bool _locked = false;

  bool locked() => _locked;

  Future<bool> acquire() async {
    if (!_locked && _waiters.isEmpty) {
      _locked = true;
      return true;
    }

    var waiter = FutureWaiter();
    _waiters.add(waiter);

    try {
      await waiter.future;
    } finally {
      _waiters.remove(waiter);
    }

    _locked = true;
    return true;
  }

  void release() {
    if (_locked) {
      _locked = false;
      _wakeUpFirst();
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
