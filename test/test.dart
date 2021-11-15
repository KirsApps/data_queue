import 'package:data_queue/data_queue.dart';
import 'package:test/test.dart';

void main() {
  final worker = QueueWorker(DataQueue<String>());

  test('EnumerateCommand', () async {
    worker.addAll(['test', 'test2']);
    final count = await worker.enumerate;
    expect(count, equals(2));
  });
  test('NextCommand', () async {
    final value = await worker.next;
    final count = await worker.enumerate;
    expect(value, equals('test'));
    expect(count, equals(1));
  });
  test('CloneCommand', () async {
    final value = await worker.clone;
    final count = await worker.enumerate;
    expect(value, equals('test2'));
    expect(count, equals(1));
  });
  test('AllCommand', () async {
    worker.addAll(['1', '2', '3']);
    final all = await worker.all;
    final count = await worker.enumerate;
    expect(all, equals(['test2', '1', '2', '3']));
    expect(count, equals(0));
  });
  test('SkipCommand', () async {
    worker.addAll(['1', '2', '3']);
    final skip = await worker.skip(3);
    final count = await worker.enumerate;
    expect(skip, equals(3));
    expect(count, equals(0));
  });
  test('TakeCommand', () async {
    worker.addAll(['1', '2', '3']);
    final take = await worker.take(3);
    final count = await worker.enumerate;
    expect(take, equals(['1', '2', '3']));
    expect(count, equals(0));
  });
}
