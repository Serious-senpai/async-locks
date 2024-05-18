part of "../async_locks.dart";

abstract class _Semaphore {
  final _waiters = ListQueue<_FutureWaiter>();
  int _value;

  _Semaphore(int value) : _value = value;

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

  _FutureWaiter _getNextWaiter();

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

  /// Cancel all futures waiting for this semaphore to be available by throwing a
  /// [SemaphoreAcquireFailureException] to them.
  void cancelAll() {
    while (_waiters.isNotEmpty) {
      var waiter = _waiters.removeFirst();
      waiter.completeError(SemaphoreAcquireFailureException());
    }
  }
}

/// A semaphore object that allows a limited number of futures to acquire it.
///
/// A semaphore is a synchronization primitive that maintains a counter indicating the number of
/// available resources or permits. In this implementation, the semaphore keeps track of an internal
/// counter. The counter is decremented each time a future acquires the semaphore using the [acquire]
/// method and incremented each time the semaphore is released using the [release] method.
///
/// When multiple futures are waiting for the semaphore, they will be put in a FIFO queue and only the
/// first one will proceed when the semaphore becomes available.
///
/// Example usage:
/// ```dart
/// final semaphore = Semaphore(2); // Create a semaphore with a limit of 2 permits
///
/// await semaphore.acquire(); // Acquire a permit
/// // Perform some asynchronous operation
/// semaphore.release(); // Release the permit
/// ```
///
/// See also: [Python documentation](https://docs.python.org/3/library/asyncio-sync.html#asyncio.Semaphore)
class Semaphore extends _Semaphore {
  /// Create a new [Semaphore] object with the initial internal counter set to [value].
  Semaphore(int value) : super(value);

  @override
  _FutureWaiter _getNextWaiter() => _waiters.removeFirst();
}

/// A semaphore object that enforces an upper bound on the internal counter.
///
/// A bounded semaphore is a synchronization primitive that limits the number of
/// concurrent accesses to a shared resource. It maintains a counter that represents
/// the number of available resources. When a future wants to access the resource,
/// it must acquire a permit from the semaphore. If no permits are available, the
/// thread will be blocked until a permit becomes available.
///
/// This implementation extends the [Semaphore] class and adds additional logic to
/// enforce a limit on the number of permits. If the value of the semaphore exceeds
/// the initial value, a [BoundedSemaphoreLimitException] is thrown when releasing
/// a permit.
class BoundedSemaphore extends Semaphore {
  final int _initial;
  final bool _error = true;

  /// Construct a new [BoundedSemaphore] object with the initial internal counter set to [value].
  /// This provided [value] is also the upper bound of the internal counter.
  ///
  /// If [error] is set to `true`, a [BoundedSemaphoreLimitException] will be thrown when the
  /// internal counter exceeds the initial value. If set to `false`, this exception will be
  /// suppressed.
  BoundedSemaphore(int value, {bool error = true})
      : _initial = value,
        super(value);

  /// Release a permit from the semaphore. If the internal value of the semaphore is greater than the
  /// initial value, a [BoundedSemaphoreLimitException] may be thrown.
  ///
  /// Whether an instance of [BoundedSemaphoreLimitException] is thrown depends on the value of the
  /// `error` parameter in the constructor.
  @override
  void release() {
    super.release();
    if (_value > _initial) {
      _value = _initial;
      if (_error) {
        throw BoundedSemaphoreLimitException();
      }
    }
  }
}
