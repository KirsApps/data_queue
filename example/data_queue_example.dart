import 'package:data_queue/data_queue.dart';

void main() {
  final worker = QueueWorker(DataQueue<String>());
  worker.add('test'); // In the eventQueue now one event - 'test'.
  worker.addAll([
    'test2',
    'test3'
  ]); // In the eventQueue now three events - 'test', 'test2', 'test3'.
  final next = worker.next; // result = test
  final take = worker.take(2); // take = 'test2', 'test3'
  final count = worker.enumerate; // count = 0, eventQueue is empty.
}
