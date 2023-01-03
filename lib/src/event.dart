part of async_locks;

/// An event object to notify multiple futures that an event has happened.
///
/// See [Python documentation](https://docs.python.org/3.9/library/asyncio-sync.html#asyncio.Event)
class Event {
  final _waiters = <_FutureWaiter>[];
  bool _flag = false;

  /// Create a new [Event] object with the internal flag set to `false`
  Event();

  /// The boolean value of the internal flag.
  bool get isSet => _flag;

  /// Number of futures which are currently waiting for this Event to set.
  int get waiters => _waiters.length;

  /// Set the internal flag to `true`, wake up any futures waiting for this event.
  void set() {
    if (_flag) return;
    _flag = true;

    for (var waiter in _waiters) {
      if (!waiter.isCompleted) waiter.complete();
    }
  }

  /// Set the internal flag to `false`.
  void clear() => _flag = false;

  /// Wait for the internal flag to become `true`. If it is `true` already then this method
  /// will return immediately.
  Future<void> wait() async {
    if (_flag) return;

    var waiter = _FutureWaiter();
    _waiters.add(waiter);

    try {
      await waiter.future;
      return;
    } finally {
      _waiters.remove(waiter);
    }
  }
}
