import 'package:flutter/material.dart';
import 'package:dartea/dartea.dart';
import 'dart:async';

void main() {
  final program = Program<Model, Message, Timer>(
          init, //create app initial state
          update, //handle messages and returns updated state + side effects
          view, //create UI
          /* optional functions */
          subscription:
              _periodicTimerSubscription, //mange subscription to external source
          lifeCycleUpd:
              lifeCycleUpdate, //handle Flutter lifecycle events and returns updated state + side effects
          onError: (s, e) =>
              debugPrint('Handle app error: $e\n$s')) //handle all errors
      .withDebugTrace(); //Output to the console all the messages, model changes and etc.
  runApp(MyApp(program));
}

class MyApp extends StatelessWidget {
  final Program darteaProgram;

  MyApp(this.darteaProgram);

  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'Flutter MVU example',
      theme: new ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: darteaProgram.build(key: Key('root_key')),
    );
  }
}

///Model - immutable application state
class Model {
  final int counter;
  final bool autoIncrement;
  Model(this.counter, this.autoIncrement);
  Model copyWith({int counter, bool autoIncrement}) =>
      Model(counter ?? this.counter, autoIncrement ?? this.autoIncrement);

  @override
  String toString() => '{counter:$counter, autoIncrement:$autoIncrement}';
}

///Messages - described actions and events, which could affect [Model]
abstract class Message {}

class Increment implements Message {
  @override
  String toString() => 'Increment';
}

class Decrement implements Message {
  @override
  String toString() => 'Decrement';
}

class StartAutoIncrement implements Message {
  @override
  String toString() => 'StartAutoIncrement';
}

class StopAutoIncrement implements Message {
  @override
  String toString() => 'StopAutoIncrement';
}

///create initial [Model] + side-effects (optional)
Upd<Model, Message> init() => Upd(Model(0, false));

///Update - the heart of the [dartea] program. Handle messages and current model, returns updated model + side-effects(optional).
Upd<Model, Message> update(Message msg, Model model) {
  if (msg is Increment) {
    return Upd(model.copyWith(counter: model.counter + 1));
  }
  if (msg is Decrement) {
    return Upd(model.copyWith(counter: model.counter - 1));
  }
  if (msg is StartAutoIncrement) {
    return Upd(model.copyWith(autoIncrement: true));
  }
  if (msg is StopAutoIncrement) {
    return Upd(model.copyWith(autoIncrement: false));
  }
  return Upd(model);
}

///Simple timer for emulating some external events
const _timeout = const Duration(seconds: 1);
Timer _periodicTimerSubscription(
    Timer currentTimer, Dispatch<Message> dispatch, Model model) {
  if (model == null) {
    currentTimer?.cancel();
    return null;
  }
  if (model.autoIncrement) {
    if (currentTimer == null) {
      return Timer.periodic(_timeout, (_) => dispatch(Increment()));
    }
    return currentTimer;
  }
  currentTimer?.cancel();
  return null;
}

///Handle app lifecycle events, almost the same as [update] function
Upd<Model, Message> lifeCycleUpdate(AppLifecycleState appState, Model model) {
  switch (appState) {
    case AppLifecycleState.inactive:
    case AppLifecycleState.paused:
    case AppLifecycleState.suspending:
      return Upd(model.copyWith(autoIncrement: false));
    case AppLifecycleState.resumed:
    default:
      return Upd(model);
  }
}

///View - maps [Model] to the Flutter's Widgets tree
Widget view(BuildContext context, Dispatch<Message> dispatch, Model model) {
  return Scaffold(
    appBar: AppBar(
      title: Text('Flutter MVU example'),
    ),
    body: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Text(
            '${model.counter}',
            style: Theme.of(context).textTheme.display1,
          ),
          Padding(
            child: RaisedButton.icon(
              label: Text('Increment'),
              icon: Icon(Icons.add),
              onPressed:
                  model.autoIncrement ? null : () => dispatch(Increment()),
            ),
            padding: EdgeInsets.all(5.0),
          ),
          RaisedButton.icon(
            label: Text('Decrement'),
            icon: Icon(Icons.remove),
            onPressed: model.autoIncrement ? null : () => dispatch(Decrement()),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Switch(
                value: model.autoIncrement,
                onChanged: (v) =>
                    dispatch(v ? StartAutoIncrement() : StopAutoIncrement()),
              ),
              Text('Auto increment every second')
            ],
          )
        ],
      ),
    ),
  );
}
