import 'package:meta/meta.dart';

import 'commands.dart';
import 'data_queue.dart';

/// The class handles the [dataQueue] with built-in commands.
class QueueWorker<TEvent> {
  /// Creates [QueueWorker] handles the [dataQueue] with built-in commands.
  QueueWorker(this.dataQueue);

  /// Adds the [event] to the events queue.
  void add(TEvent event) => dataQueue.add(event);

  /// Adds all [events] to the events queue in the iteration order.
  void addAll(List<TEvent> events) => dataQueue.addAll(events);

  /// Terminates all commands by throwing the [TerminateException].
  void terminate() => dataQueue.terminate();

  /// The Data queue
  @protected
  final DataQueue<TEvent> dataQueue;

  /// Returns all events from the [dataQueue].
  Future<List<TEvent>> get all => dataQueue.execute<List<TEvent>>(AllCommand());

  /// Returns an event from the [dataQueue] without consuming it.
  Future<TEvent> get clone => dataQueue.execute<TEvent>(CloneCommand());

  /// Returns an event count in the [dataQueue].
  Future<int> get count => dataQueue.execute(CountCommand());

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
