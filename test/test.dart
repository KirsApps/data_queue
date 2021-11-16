import 'package:data_queue/data_queue.dart';
import 'package:test/test.dart';

void main() {
  final worker = QueueWorker(DataQueue<String>());

  test('EnumerateCommand', () async {
    worker.add('test');
    worker.add('test2');
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
  test('Several commands', () async {
    final result = await Future.wait([
      Future.delayed(Duration(milliseconds: 300), () {
        worker.addAll(['1', '2', '3']);
      }),
      worker.take(3),
      worker.enumerate
    ]);
    expect(result[1], equals(['1', '2', '3']));
    expect(result[2], equals(0));
  });
  test('Terminate', () async {
    expect(
        () async => await Future.wait([
              Future.delayed(Duration(milliseconds: 300), () {
                worker.terminate();
              }),
              worker.take(3),
              worker.enumerate
            ]),
        throwsA(isA<TerminatedException>()));
  });
}
