part of async_locks;

/// An event object to notify multiple futures that an event has happened.
///
/// See [Python documentation](https://docs.python.org/3.9/library/asyncio-sync.html#asyncio.Event)
class Event {
  final _waiters = <_FutureWaiter>[];
  bool _value = false;

  /// Create a new [Event] object with the internal flag set to `false`
  Event();

  /// The boolean value of the internal flag.
  bool get isSet => _value;

  /// Set the internal flag to `true`, wake up any futures waiting for this event.
  void set() {
    if (_value) return;
    _value = true;

    for (var waiter in _waiters) {
      if (!waiter.isCompleted) waiter.complete();
    }
  }

  /// Set the internal flag to `false`.
  void clear() => _value = false;

  /// Wait for the internal flag to become `true`. If it is true already then this future
  /// will return immediately.
  ///
  /// This method always returns `true`.
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
