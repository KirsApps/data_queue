import 'package:meta/meta.dart';

import 'commands.dart';
import 'data_queue.dart';

class QueueWorker<TEvent> {
  QueueWorker(this.executorQueue);
  @protected
  final DataQueue<TEvent> executorQueue;

  Future<List<TEvent>> get all =>
      executorQueue.execute<List<TEvent>>(AllCommand());

  Future<TEvent> get clone => executorQueue.execute<TEvent>(CloneCommand());

  Future<int> get enumerate => executorQueue.execute(EnumerateCommand());

  Future<TEvent> get next => executorQueue.execute<TEvent>(NextCommand());

  Future<int> skip(int count) {
    RangeError.checkNotNegative(count, 'count');
    return executorQueue.execute<int>(SkipCommand(count));
  }

  Future<List<TEvent>> take(int count) {
    RangeError.checkNotNegative(count, 'count');
    return executorQueue.execute<List<TEvent>>(TakeCommand(count));
  }
}
