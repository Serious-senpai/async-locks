part of async_locks;

/// Documentation at https://docs.python.org/3.9/library/asyncio-sync.html#asyncio.Event
class Event {
  final List<_FutureWaiter> _waiters = [];
  bool _value = false;

  /// The boolean value of the internal flag.
  bool isSet() => _value;

  /// Set the internal flag to `true`, wake up any futures waiting for this event.
  void set() {
    if (_value) return;
    _value = true;

    for (int i = 0; i < _waiters.length; i++) {
      var waiter = _waiters[i];
      if (!waiter.isCompleted) waiter.complete();
    }
  }

  /// Set the internal flag to `false`, asynchronously block any futures waiting for this
  /// event until [set] is called.
  void clear() => _value = false;

  /// Wait for the internal flag to become `true`. If it is true already then this future
  /// will return immediately.
  ///
  /// Always return `true`.
  Future<bool> wait() async {
    if (_value) return true;

    var waiter = _FutureWaiter();
    _waiters.add(waiter);

    try {
      await waiter.future;
      return true;
    } finally {
      _waiters.remove(waiter);
    }
  }
}
