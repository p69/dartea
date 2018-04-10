library dartea;

import 'dart:async';
import 'package:flutter/widgets.dart';
import 'package:flutter/foundation.dart';
import 'package:collection/collection.dart';

part 'src/types.dart';
part 'src/cmd.dart';
part 'src/widget.dart';

/// Entry point to the Dartea application
class Program<TArg, TModel, TMsg> {
  final Init<TArg, TModel, TMsg> init;
  final Update<TModel, TMsg> update;
  final Subscribe<TModel, TMsg> subscribe;
  final View<TModel, TMsg> view;
  final OnError onError;
  StreamController<TMsg> _controller;

  Program(this.init, this.update, this.subscribe, this.view, this.onError);

  static Program<TArg, TModel, TMsg> mkSimple<TArg, TModel, TMsg>(
      Init<TArg, TModel, TMsg> init,
      Update<TModel, TMsg> update,
      View<TModel, TMsg> view) {
    return new Program(init, update, (_) => Cmd.none, view,
        (d, e) => debugPrint("Program loop: $d $e"));
  }

  Program<TArg, TModel, TMsg> copyWith(
      {Init<TArg, TModel, TMsg> init,
      Update<TModel, TMsg> update,
      View<TModel, TMsg> view,
      Subscribe<TModel, TMsg> subscribe,
      OnError onError}) {
    return new Program(
        init ?? this.init,
        update ?? this.update,
        subscribe ?? this.subscribe,
        view ?? this.view,
        onError ?? this.onError);
  }

  void runWith<T extends Widget>(RenderView render, TArg arg) {
    var initial = init(arg);
    var initialModel = initial.model;
    var initialEffects = new List<Sub>();
    initialEffects.addAll(initial.effects);
    var currentModel = initialModel;
    _controller = new StreamController<TMsg>();

    Dispatch dispatch = (m) => _controller.add(m);

    var root = new DarteaAppWidget(dispatch, view, currentModel);

    _controller.stream.listen((msg) {
      debugPrint("Program loop: handle message $msg");
      try {
        var updates = update(msg, currentModel);
        currentModel = updates.model;
        root = new DarteaAppWidget(dispatch, view, currentModel);
        render(root);
        for (var effect in updates.effects) {
          effect(dispatch);
        }
      } on Exception catch (e) {
        onError("Failed while processing message.", e);
      }
    });

    render(root);
    initialEffects.addAll(subscribe(currentModel));
    initialEffects.forEach((effect) => effect(dispatch));
  }
}
