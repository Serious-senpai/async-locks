/// Synchronization Primitives
///
/// See https://docs.python.org/3.9/library/asyncio-sync.html for documentation and
/// https://github.com/python/cpython/blob/3.9/Lib/asyncio/locks.py for original
/// implementation.
library async_locks;

import "dart:async";

part "src/event.dart";
part "src/lock.dart";
part "src/types.dart";
