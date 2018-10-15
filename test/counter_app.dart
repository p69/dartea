import 'package:dartea/dartea.dart';
import 'package:flutter/material.dart';

class Model {
  int counter;
  Cmd<Message> effect;
  Key incrementBtnKey;
  Key decrementBtnKey;
  Key incrementToMessagesBusBtnKey;

  Model({
    this.counter = 0,
    this.effect,
    this.incrementBtnKey,
    this.decrementBtnKey,
    this.incrementToMessagesBusBtnKey,
  });
  Model copyWith({int counter, Cmd<Message> effect}) => Model(
        counter: counter ?? this.counter,
        effect: effect ?? this.effect,
        incrementBtnKey: this.incrementBtnKey,
        decrementBtnKey: this.decrementBtnKey,
        incrementToMessagesBusBtnKey: this.incrementToMessagesBusBtnKey,
      );
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

Upd<Model, Message> init(
  int start, {
  Cmd<Message> effect,
  Key incrementBtnKey,
  Key decrementBtnKey,
  Key incrementToMessagesBusBtnKey,
}) =>
    Upd(Model(
        counter: start,
        effect: effect,
        incrementBtnKey: incrementBtnKey,
        decrementBtnKey: decrementBtnKey,
        incrementToMessagesBusBtnKey: incrementToMessagesBusBtnKey));

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
  return Upd(model);
}

const incrementBtnKey = const Key("incremet");
const decrementBtnKey = const Key("decremet");
const effectBtnKey = const Key("effect");
const incrementToMessagesBusBtnKey = const Key("msgBusIncrement");

Widget view(BuildContext ctx, Dispatch<Message> d, Model m) {
  return Column(
    children: <Widget>[
      Center(child: Text(m.counter.toString())),
      Center(
        child: Column(
          children: <Widget>[
            RaisedButton(
                key: m.incrementBtnKey ?? incrementBtnKey,
                onPressed: () => d(Increment()),
                child: Text("increment")),
            RaisedButton(
              key: m.decrementBtnKey ?? decrementBtnKey,
              onPressed: () => d(Decrement()),
              child: Text("decrement"),
            ),
            RaisedButton(
              key: effectBtnKey,
              onPressed: () => d(DoSideEffect()),
              child: Text("do side effect"),
            ),
            RaisedButton(
              key: m.incrementToMessagesBusBtnKey ??
                  incrementToMessagesBusBtnKey,
              onPressed: () {
                final dispatchToBus = DarteaMessagesBus.dispatchOf(ctx);
                if (dispatchToBus != null) {
                  dispatchToBus(Increment());
                }
              },
              child: Text('Dispatch to messages bus'),
            ),
          ],
        ),
      )
    ],
  );
}
