import 'dart:async';
import 'dart:collection';

import 'package:meta/meta.dart';

import 'commands.dart';

class DataQueue<TEvent> {
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
