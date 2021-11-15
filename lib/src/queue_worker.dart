import 'package:meta/meta.dart';

import 'commands.dart';
import 'data_queue.dart';

/// The class handles the [dataQueue] with built-in commands.
class QueueWorker<TEvent> {
  /// Creates [QueueWorker] handles the [dataQueue] with built-in commands.
  QueueWorker(this.dataQueue);

  /// The Data queue
  @protected
  final DataQueue<TEvent> dataQueue;

  /// Returns all events from the [dataQueue].
  Future<List<TEvent>> get all => dataQueue.execute<List<TEvent>>(AllCommand());

  /// Returns an event from the [dataQueue] without consuming it.
  Future<TEvent> get clone => dataQueue.execute<TEvent>(CloneCommand());

  /// Returns events count in the [dataQueue].
  Future<int> get enumerate => dataQueue.execute(EnumerateCommand());

  /// Returns next event in the [dataQueue].
  Future<TEvent> get next => dataQueue.execute<TEvent>(NextCommand());

  /// Skips the next [count] events in the [dataQueue]
  ///
  /// The [count] must be non-negative.
  Future<int> skip(int count) {
    RangeError.checkNotNegative(count, 'count');
    return dataQueue.execute<int>(SkipCommand(count));
  }

  /// Returns a list with the next [count] events from the [dataQueue]
  ///
  /// The [count] must be non-negative.
  Future<List<TEvent>> take(int count) {
    RangeError.checkNotNegative(count, 'count');
    return dataQueue.execute<List<TEvent>>(TakeCommand(count));
  }
}
