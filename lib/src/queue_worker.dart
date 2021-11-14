import 'package:meta/meta.dart';

import 'commands.dart';
import 'data_queue.dart';

class QueueWorker<TEvent> {
  QueueWorker(this.dataQueue);
  @protected
  final DataQueue<TEvent> dataQueue;

  Future<List<TEvent>> get all => dataQueue.execute<List<TEvent>>(AllCommand());

  Future<TEvent> get clone => dataQueue.execute<TEvent>(CloneCommand());

  Future<int> get enumerate => dataQueue.execute(EnumerateCommand());

  Future<TEvent> get next => dataQueue.execute<TEvent>(NextCommand());

  Future<int> skip(int count) {
    RangeError.checkNotNegative(count, 'count');
    return dataQueue.execute<int>(SkipCommand(count));
  }

  Future<List<TEvent>> take(int count) {
    RangeError.checkNotNegative(count, 'count');
    return dataQueue.execute<List<TEvent>>(TakeCommand(count));
  }
}
