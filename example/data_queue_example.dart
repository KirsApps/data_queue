import 'package:data_queue/data_queue.dart';

Future<void> main() async {
  final worker = QueueWorker(DataQueue<String>());
  worker.add('test'); // In the eventQueue now one event - 'test'.
  worker.addAll([
    'test2',
    'test3'
  ]); // In the eventQueue now three events - 'test', 'test2', 'test3'.
  await worker.next; // result = test
  await worker.take(2); // take = 'test2', 'test3'
  await worker.count; // count = 0, eventQueue is empty.
}
