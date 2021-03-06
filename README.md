[![codecov](https://codecov.io/gh/KirsApps/data_queue/branch/master/graph/badge.svg)](https://codecov.io/gh/KirsApps/data_queue)
[![Build Status](https://github.com/KirsApps/data_queue/workflows/build/badge.svg)](https://github.com/KirsApps/data_queue/actions?query=workflow%3A"build"+branch%3Amaster)
[![pub](https://img.shields.io/pub/v/data_queue.svg)](https://pub.dev/packages/data_queue)
[![style: lint](https://img.shields.io/badge/style-lint-4BC0F5.svg)](https://pub.dev/packages/lint)

Asynchronous pull-based class for accessing data

## DataQueue

This class is the main for building data access functionality. It manages eventsQueue (added data) and commandsQueue (added commands).
You can add data with add and addAll methods. Data access is available with commands passed to the execute method.

Basic usage:

```dart
final dataQueue = DataQueue<String>();
dataQueue.add('test'); // In the dataQueue now one event - 'test'.
final next = await dataQueue.execute(NextCommand()); // result = test
```

## QueueWorker

The QueueWorker class provides commands and a more simple way to data manipulating than DataQueue.
Basic usage:

```dart
final worker = QueueWorker(DataQueue<String>());
worker.add('test'); // In the eventQueue now one event - 'test'.
worker.addAll([
'test2',
'test3'
]); // In the eventQueue now three events - 'test', 'test2', 'test3'.
final next = await worker.next; // result = test
final take = await worker.take(2); // take = 'test2', 'test3'
final count = await worker.enumerate; // count = 0, the eventQueue is empty.
```

## Commands

All commands are based on the CommandBase interface.
You can create your commands. Extend this class, and write the handle method.

Available commands:
* NextCommand - The command consumes a next event in a queue.
* TakeCommand - The command consumes the next [take] events in a queue.
* SkipCommand - The command skips the next [skip] events in a queue.
* CountCommand - The command counts all events in a queue.
* CloneCommand - The command takes an event in a queue without consuming it.
* AllCommand - The command takes all events from a queue.

## Termination

You can terminate the execution of commands by the terminate method call. All commands in the queue will be complete with TerminatedException. The TerminatedException contains a command and optional command data.

