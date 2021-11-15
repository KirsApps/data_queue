import 'package:meta/meta.dart';

import 'commands.dart';
import 'data_queue.dart';

/// The class handles [dataQueue] with built-in commands.
class QueueWorker<TEvent> {
  /// Creates [QueueWorker] handles [dataQueue] with built-in commands.
  QueueWorker(this.dataQueue);

  /// Data queue
  @protected
  final DataQueue<TEvent> dataQueue;

  /// Returns all events from [dataQueue].
  Future<List<TEvent>> get all => dataQueue.execute<List<TEvent>>(AllCommand());

  /// Returns an event from [dataQueue] without consuming it.
  Future<TEvent> get clone => dataQueue.execute<TEvent>(CloneCommand());

  /// Returns events count in [dataQueue].
  Future<int> get enumerate => dataQueue.execute(EnumerateCommand());

  /// Returns next event in [dataQueue].
  Future<TEvent> get next => dataQueue.execute<TEvent>(NextCommand());

  /// Skips next [count] events in [dataQueue]
  ///
  /// The [count] must be non-negative.
  Future<int> skip(int count) {
    RangeError.checkNotNegative(count, 'count');
    return dataQueue.execute<int>(SkipCommand(count));
  }

  /// Returns list with next [count] events from [dataQueue]
  ///
  /// The [count] must be non-negative.
  Future<List<TEvent>> take(int count) {
    RangeError.checkNotNegative(count, 'count');
    return dataQueue.execute<List<TEvent>>(TakeCommand(count));
  }
}
