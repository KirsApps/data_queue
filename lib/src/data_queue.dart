import 'dart:async';
import 'dart:collection';

import 'package:meta/meta.dart';

import 'commands.dart';

/// The exception indicates that a future was terminated
/// by calling [DataQueue.terminate].
class TerminatedException<T> implements Exception {
  /// Creates exception that indicates a future was terminated
  /// by calling [DataQueue.terminate]
  TerminatedException(this.command, {this.data});

  /// The terminated command.
  final CommandBase command;

  /// The optional command data.
  final T? data;
  @override
  String toString() =>
      'The future terminated by calling the DataQueue.terminate';
}

/// The class handles event and command queues.
///
/// Events manipulating available with [CommandBase] commands.
class DataQueue<TEvent> {
  /// The events queue
  final _eventsQueue = ListQueue<TEvent>();

  /// The commands queue
  final _commandsQueue = ListQueue<CommandBase>();

  /// Adds the [event] to the events queue.
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

  /// Adds all [events] to the events queue in iteration order.
  @mustCallSuper
  void addAll(List<TEvent> events) {
    for (final event in events) {
      add(event);
    }
  }

  /// Adds the command to the commands queue.
  @mustCallSuper
  Future<TResult> execute<TResult>(CommandBase<TEvent, TResult> command) {
    if (_commandsQueue.isNotEmpty ||
        _commandsQueue.isEmpty && !command.handle(_eventsQueue)) {
      _commandsQueue.add(command);
    }
    return command.future;
  }

  /// Terminates all commands by throwing [TerminateException].
  void terminate() {
    final commands = ListQueue.from(_commandsQueue);
    _commandsQueue.clear();
    for (final command in commands) {
      command.terminate();
    }
  }
}
