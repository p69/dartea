import 'package:dartea/dartea.dart';
import 'package:flutter/material.dart';

class Model {
  int counter;
  Cmd<Message> effect;
  Model({this.counter = 0, this.effect});
  Model copyWith({int counter, Cmd<Message> effect}) =>
      Model(counter: counter ?? this.counter, effect: effect ?? this.effect);
}

abstract class Message {}

class Increment implements Message {}

class Decrement implements Message {}

class DoSideEffect implements Message {}

class ErrorMessage implements Message {
  final String message;
  ErrorMessage(this.message);
}

class OnSuccessEffect implements Message {}

class OnSuccessEffectWithResult implements Message {
  final String result;
  OnSuccessEffectWithResult(this.result);
}

Upd<Model, Message> init(int start, {Cmd<Message> effect}) =>
    new Upd(new Model(counter: start, effect: effect));

Upd<Model, Message> update(Message msg, Model model) {
  if (msg is Increment) {
    return Upd(model.copyWith(counter: model.counter + 1));
  }
  if (msg is Decrement) {
    return Upd(model.copyWith(counter: model.counter - 1));
  }
  if (msg is DoSideEffect) {
    return Upd(model, effects: model.effect);
  }
  return new Upd(model);
}

const incrementBtnKey = const Key("incremet");
const decrementBtnKey = const Key("decremet");
const effectBtnKey = const Key("effect");

Widget view(BuildContext ctx, Dispatch<Message> d, Model m) {
  return new Column(
    children: <Widget>[
      new Center(child: new Text(m.counter.toString())),
      new Center(
          child: new Row(
        children: <Widget>[
          new RaisedButton(
              key: incrementBtnKey,
              onPressed: () => d(new Increment()),
              child: new Text("increment")),
          new RaisedButton(
            key: decrementBtnKey,
            onPressed: () => d(new Decrement()),
            child: new Text("decrement"),
          ),
          new RaisedButton(
            key: effectBtnKey,
            onPressed: () => d(new DoSideEffect()),
            child: new Text("do side effect"),
          )
        ],
      ))
    ],
  );
}
