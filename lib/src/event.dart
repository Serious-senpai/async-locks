part of "../async_locks.dart";

/// Event object to notify multiple futures that an event has happened.
///
/// An event object manages an internal flag. If the flag is `true`, any calls to [wait] will
/// return immediately. If the flag is `false`, the [wait] method will suspend the current future
/// and wait for the flag to become `true` before returning.
///
/// The internal flag can be switched by [set] and [clear] methods. The [isSet] property check
/// if the flag is currently `true`.
///
/// See also: [Python documentation](https://docs.python.org/3/library/asyncio-sync.html#asyncio.Event)
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

    for (final waiter in _waiters) {
      if (!waiter.isCompleted) waiter.complete();
    }

    _waiters.clear();
  }

  /// Set the internal flag to `false`.
  void clear() => _flag = false;

  /// Wait for the internal flag to become `true`. If it is `true` already then this method
  /// will return immediately.
  Future<void> wait() async {
    if (_flag) return;

    final waiter = _FutureWaiter();
    _waiters.add(waiter);

    return waiter.future;
  }

  /// Cancel all futures waiting for this [Event] to be set (those that are waiting for [wait]
  /// to return). This function throws an [EventCancelledException] to all these futures.
  void cancelAll() {
    for (final waiter in _waiters) {
      waiter.completeError(EventCancelledException());
    }

    _waiters.clear();
  }
}
