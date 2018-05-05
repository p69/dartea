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
      .withDebugTrace();
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
abstract class Message {
  @override
  String toString() => '${this.runtimeType}';
}

class Increment implements Message {}

class Decrement implements Message {}

class StartAutoIncrement implements Message {}

class StopAutoIncrement implements Message {}

class RaiseError implements Message {}

Upd<Model, Message> init() => Upd(Model(0, false));

///Update - the heart of the [dartea] program. Handle messages and current model, returns updated model.
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
  if (msg is RaiseError) {
    throw Exception('Wow, error!'); // all exception goes to Program.onError
  }
  return Upd(model);
}

const _timeout = const Duration(seconds: 1);
Timer _periodicTimerSubscription(
    Timer currentTimer, Dispatch<Message> dispatch, Model model) {
  if (model.autoIncrement) {
    if (currentTimer == null) {
      return Timer.periodic(_timeout, (_) => dispatch(Increment()));
    }
    return currentTimer;
  }
  currentTimer?.cancel();
  return null;
}

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
  return new Scaffold(
    appBar: new AppBar(
      title: new Text('Flutter MVU example'),
    ),
    body: new Center(
      child: new Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          new Text(
            'You have pushed the button this many times:',
          ),
          new Text(
            '${model.counter}',
            style: Theme.of(context).textTheme.display1,
          ),
          new Padding(
            child: new RaisedButton.icon(
              label: new Text('Increment'),
              icon: new Icon(Icons.add),
              onPressed:
                  model.autoIncrement ? null : () => dispatch(Increment()),
            ),
            padding: EdgeInsets.all(5.0),
          ),
          new RaisedButton.icon(
            label: new Text('Decrement'),
            icon: new Icon(Icons.remove),
            onPressed: model.autoIncrement ? null : () => dispatch(Decrement()),
          ),
          new Row(
            children: <Widget>[
              new Switch(
                value: model.autoIncrement,
                onChanged: (v) =>
                    dispatch(v ? StartAutoIncrement() : StopAutoIncrement()),
              ),
              new Text('Auto increment every second')
            ],
          )
        ],
      ),
    ),
    floatingActionButton: new FloatingActionButton(
      onPressed: () => dispatch(RaiseError()),
      tooltip: 'Increment',
      child: new Icon(Icons.error),
    ),
  );
}
