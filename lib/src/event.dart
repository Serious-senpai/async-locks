part of async_locks;

/// Documentation at https://docs.python.org/3.9/library/asyncio-sync.html#asyncio.Event
class Event {
  final List<FutureWaiter> _waiters = [];
  bool _value = false;

  bool isSet() => _value;

  void set() {
    if (_value) return;
    _value = true;

    for (int i = 0; i < _waiters.length; i++) {
      var waiter = _waiters[i];
      if (!waiter.isCompleted) waiter.complete();
    }
  }

  void clear() => _value = false;

  Future<bool> wait() async {
    if (_value) return true;

    var waiter = FutureWaiter();
    _waiters.add(waiter);

    try {
      await waiter.future;
      return true;
    } finally {
      _waiters.remove(waiter);
    }
  }
}
