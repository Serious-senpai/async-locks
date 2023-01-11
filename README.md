# async-locks
Synchronization primitives for asynchronous Dart code, inspired from Python.

The usage of these primitives is similar to those in Python although the implementation is slightly different.
#### With `Event`
Mutex lock to guarantee exclusive access to a shared state.
#### With `Lock`
Event object to notify multiple futures that an event has happened.
#### With `Semaphore`
Semaphore object which allows a number of futures to acquire it.
