import 'dart:async';
import 'dart:collection';

import 'package:meta/meta.dart';

import 'commands.dart';

class ExecutorQueue<TEvent> {
  final _eventQueue = ListQueue<TEvent>();
  final _commandQueue = ListQueue<CommandBase>();

  @mustCallSuper
  void add(TEvent event) {
    _eventQueue.add(event);
    while (_commandQueue.isNotEmpty) {
      if (_commandQueue.first.handle(_eventQueue)) {
        _commandQueue.removeFirst();
      } else {
        return;
      }
    }
  }

  @mustCallSuper
  Future<TResult> execute<TResult>(CommandBase<TEvent, TResult> command) {
    if (_commandQueue.isNotEmpty ||
        _commandQueue.isEmpty && !command.handle(_eventQueue)) {
      _commandQueue.add(command);
    }
    return command.future;
  }
}

class QueueWorker<TEvent> {
  QueueWorker(this.executorQueue);
  @protected
  final ExecutorQueue<TEvent> executorQueue;

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
