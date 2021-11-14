import 'dart:async';
import 'dart:collection';

import 'package:meta/meta.dart';

abstract class CommandBase<TEvent, TResult> {
  @protected
  final completer = Completer<TResult>();
  Future<TResult> get future => completer.future;
  bool handle(ListQueue<TEvent> eventQueue);
}

class NextCommand<TEvent> extends CommandBase<TEvent, TEvent> {
  @override
  bool handle(ListQueue<TEvent> eventQueue) {
    if (eventQueue.isNotEmpty) {
      completer.complete(eventQueue.removeFirst());
      return true;
    } else {
      return false;
    }
  }
}

class TakeCommand<TEvent> extends CommandBase<TEvent, List<TEvent>> {
  final _buffer = <TEvent>[];
  final int _take;
  TakeCommand(this._take);

  @override
  bool handle(ListQueue<TEvent> eventQueue) {
    while (_buffer.length < _take) {
      if (eventQueue.isNotEmpty) {
        _buffer.add(eventQueue.removeFirst());
      } else {
        return false;
      }
    }
    completer.complete(_buffer);
    return true;
  }
}

class SkipCommand<TEvent> extends CommandBase<TEvent, int> {
  final int _skip;
  int _skipped = 0;
  SkipCommand(this._skip);

  @override
  bool handle(ListQueue<TEvent> eventQueue) {
    while (_skipped < _skip) {
      if (eventQueue.isNotEmpty) {
        _skipped++;
        eventQueue.removeFirst();
      } else {
        return false;
      }
    }
    completer.complete(_skip);
    return true;
  }
}

class EnumerateCommand<TEvent> extends CommandBase<TEvent, int> {
  EnumerateCommand();

  @override
  bool handle(ListQueue<TEvent> eventQueue) {
    completer.complete(eventQueue.length);
    return true;
  }
}

class CloneCommand<TEvent> extends CommandBase<TEvent, TEvent> {
  CloneCommand();

  @override
  bool handle(ListQueue<TEvent> eventQueue) {
    if (eventQueue.isNotEmpty) {
      completer.complete(eventQueue.first);
      return true;
    } else {
      return false;
    }
  }
}

class AllCommand<TEvent> extends CommandBase<TEvent, List<TEvent>> {
  AllCommand();

  @override
  bool handle(ListQueue<TEvent> eventQueue) {
    completer.complete(eventQueue.toList(growable: false));
    return true;
  }
}
