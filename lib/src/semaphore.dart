part of async_locks;

/// Semaphore object which allows a number of futures to acquire it.
///
/// See [Python documentation](https://docs.python.org/3.9/library/asyncio-sync.html#asyncio.Semaphore)
class Semaphore {
  final _waiters = ListQueue<_FutureWaiter>();
  int _value;

  /// Create a new [Semaphore] object with the initial internal value set to [value].
  Semaphore(int value) : _value = value;

  /// Whether this semaphore cannot be acquired immediately.
  bool get locked => _value == 0;

  /// Number of futures which are currently waiting to acquire this semaphore.
  int get waiters => _waiters.length;

  /// Acquire the semaphore.
  ///
  /// If the internal value is greater then 0, decrease it by 1 and return immediately.
  /// If the internal value equals 0, wait asynchronously until another future calls [release].
  Future<void> acquire() async {
    if (_value > 0 && _waiters.isEmpty) {
      _value--;
      return;
    }

    var waiter = _FutureWaiter();
    _waiters.add(waiter);

    await waiter.future;
    return;
  }

  /// Increase the internal value by 1 and may wake up a future waiting for this semaphore.
  void release() {
    if (_waiters.isEmpty) {
      _value++;
    } else {
      var waiter = _waiters.removeFirst();
      waiter.complete();
    }
  }

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
}
