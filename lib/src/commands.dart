import 'dart:async';
import 'dart:collection';

import 'package:data_queue/data_queue.dart';
import 'package:meta/meta.dart';

/// Abstract command class that receives events
abstract class CommandBase<TEvent, TResult> {
  /// The completer manipulates the future returned by [future].
  @protected
  final completer = Completer<TResult>();

  /// Returns the future, which will be complete when the command conditions are met.
  Future<TResult> get future => completer.future;

  /// Handle available events.
  ///
  /// Returns `true` if the command is completed, or `false` if it needs
  /// more events.
  ///
  /// If the method returns true, the command will never be called again.
  ///
  /// This method is called when a command reaches the front of the command
  /// queue, and if it returns `false`, it's called again every time a new event
  /// becomes available.
  bool handle(ListQueue<TEvent> eventQueue);

  /// Terminates this command by throwing the [TerminateException].
  ///
  /// [DataQueue.terminate] calls this method for each command in the queue.
  void terminate() =>
      completer.completeError(TerminatedException<TResult>(this));
}

/// The command consumes a next event in a queue.
///
/// The returned future will be complete when a requested event arrives.
///
/// If several [NextCommand] commands are registered,
/// they will complete in the requested order.
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

/// The command consumes the next [take] events in a queue.
///
/// The returned future will complete when the needed count of events arrives.
class TakeCommand<TEvent> extends CommandBase<TEvent, List<TEvent>> {
  final _buffer = <TEvent>[];

  /// How many events are to consume.
  final int take;

  /// Creates [TakeCommand] that consumes the next [take] events in a queue.
  TakeCommand(this.take);

  @override
  bool handle(ListQueue<TEvent> eventQueue) {
    while (_buffer.length < take) {
      if (eventQueue.isNotEmpty) {
        _buffer.add(eventQueue.removeFirst());
      } else {
        return false;
      }
    }
    completer.complete(_buffer);
    return true;
  }

  /// Completes the future with the [TerminatedException] that contains the [_buffer] as data.
  @override
  void terminate() => completer
      .completeError(TerminatedException<List<TEvent>>(this, data: _buffer));
}

/// The command skips the next [skip] events in a queue.
///
/// The returned future will complete when the needed count of events skips.
class SkipCommand<TEvent> extends CommandBase<TEvent, int> {
  /// How many events are to skip.
  final int skip;
  int _skipped = 0;

  /// Creates [SkipCommand] that skips the next [skip] events in a queue.
  SkipCommand(this.skip);

  @override
  bool handle(ListQueue<TEvent> eventQueue) {
    while (_skipped < skip) {
      if (eventQueue.isNotEmpty) {
        _skipped++;
        eventQueue.removeFirst();
      } else {
        return false;
      }
    }
    completer.complete(skip);
    return true;
  }
}

/// The command counts all events in a queue.
///
/// The returned future will be complete with an event count in a queue.
class CountCommand<TEvent> extends CommandBase<TEvent, int> {
  /// Creates [CountCommand] that counts all events in a queue.
  CountCommand();

  @override
  bool handle(ListQueue<TEvent> eventQueue) {
    completer.complete(eventQueue.length);
    return true;
  }
}

/// The command takes an event in a queue without consuming it.
class CloneCommand<TEvent> extends CommandBase<TEvent, TEvent> {
  /// Creates [CloneCommand] that takes an event in a queue without consuming it.
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

/// The command takes all events from a queue.
class AllCommand<TEvent> extends CommandBase<TEvent, List<TEvent>> {
  /// Creates [AllCommand] that takes all events from a queue.
  AllCommand();

  @override
  bool handle(ListQueue<TEvent> eventQueue) {
    completer.complete(eventQueue.toList(growable: false));
    eventQueue.clear();
    return true;
  }
}
