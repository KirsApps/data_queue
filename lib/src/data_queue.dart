import 'dart:async';
import 'dart:collection';

import 'package:meta/meta.dart';

import 'commands.dart';

/// The class handles an event and a command queue.
///
/// Events manipulating available with [CommandBase] commands.
class DataQueue<TEvent> {
  /// Events queue
  final _eventsQueue = ListQueue<TEvent>();

  /// Commands queue
  final _commandsQueue = ListQueue<CommandBase>();

  /// Adds event to event queue.
  @mustCallSuper
  void add(TEvent event) {
    _eventsQueue.add(event);
    while (_commandsQueue.isNotEmpty) {
      if (_commandsQueue.first.handle(_eventsQueue)) {
        _commandsQueue.removeFirst();
      } else {
        return;
      }
    }
  }

  /// Adds all events to the events queue in iteration order.
  @mustCallSuper
  void addAll(List<TEvent> events) {
    for (TEvent event in events) {
      add(event);
    }
  }

  /// Add command to the commands queue.
  @mustCallSuper
  Future<TResult> execute<TResult>(CommandBase<TEvent, TResult> command) {
    if (_commandsQueue.isNotEmpty ||
        _commandsQueue.isEmpty && !command.handle(_eventsQueue)) {
      _commandsQueue.add(command);
    }
    return command.future;
  }
}
