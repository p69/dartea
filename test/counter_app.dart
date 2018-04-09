import 'package:dartea/dartea.dart';
import 'package:flutter/material.dart';

class Model {
  int counter;
  Model({this.counter = 0});
}

abstract class Message {}

class Increment implements Message {}

class Decrement implements Message {}

Upd<Model, Message> init(int start) => new Upd(new Model(counter: start));

Upd<Model, Message> update(Message msg, Model model) {
  if (msg is Increment) {
    return new Upd(new Model(counter: model.counter + 1));
  }
  if (msg is Decrement) {
    return new Upd(new Model(counter: model.counter - 1));
  }
  return new Upd(model);
}

const incrementBtnKey = const Key("incremet");
const decrementBtnKey = const Key("decremet");

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
          )
        ],
      ))
    ],
  );
}
