part of async_locks;

/// Semaphore object which allows a number of futures to acquire it.
///
/// A semaphore object keeps track of an internal counter. The internal counter is decremented
/// each time a future completes [acquire] and incremented for each [release] call.
///
/// When multiple futures are waiting for the semaphore, they will be put in a queue and only
/// the first one will proceed when the semaphore is available.
///
/// See also: [Python documentation](https://docs.python.org/3.9/library/asyncio-sync.html#asyncio.Semaphore)
class Semaphore {
  final _waiters = ListQueue<_FutureWaiter>();
  int _value;

  /// Create a new [Semaphore] object with the initial internal counter set to [value].
  Semaphore(int value) : _value = value;

  /// Whether this semaphore cannot be acquired immediately.
  bool get locked => _value == 0;

  /// Number of futures which are currently waiting to acquire this semaphore.
  ///
  /// This is the length of the waiting queue.
  int get waiters => _waiters.length;

  /// Acquire the semaphore.
  /// If the internal counter is greater then 0, decrease it by 1 and return immediately.
  /// If the internal counter equals 0, wait asynchronously until the semaphore is available.
  Future<void> acquire() async {
    if (_value > 0 && _waiters.isEmpty) {
      _value--;
      return;
    }

    var waiter = _FutureWaiter();
    _waiters.add(waiter);

    return waiter.future;
  }

  /// Increase the internal counter by 1 and may wake up a future waiting to acquire this semaphore.
  void release() {
    if (_waiters.isEmpty) {
      _value++;
    } else {
      var waiter = _getNextWaiter();
      waiter.complete();
    }
  }

  _FutureWaiter _getNextWaiter() => _waiters.removeFirst();

  /// Acquire the semaphore, asynchronously run [func] and release the semaphore afterwards.
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

  /// Cancel all futures waiting for this [Semaphore] to be available by throwing a
  /// [SemaphoreAcquireFailureException] to them.
  void cancelAll() {
    while (_waiters.isNotEmpty) {
      var waiter = _waiters.removeFirst();
      waiter.completeError(SemaphoreAcquireFailureException());
    }
  }
}

/// A [UnfairSemaphore] object is identical to a [Semaphore] excepts that it wakes up the
/// last future that called [acquire] instead of the first
class UnfairSemaphore extends Semaphore {
  /// Create a new [UnfairSemaphore] object.
  UnfairSemaphore(int value) : super(value);

  @override
  _FutureWaiter _getNextWaiter() => _waiters.removeLast();
}
