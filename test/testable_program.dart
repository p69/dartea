import 'dart:async';

import 'package:dartea/dartea.dart';
import 'package:flutter/material.dart';

class TestProgram<TArg, TModel, TMsg> {
  Program<TArg, TModel, TMsg> _program;
  final _updateController = new StreamController<TMsg>();
  final _viewController = new StreamController<TModel>();
  List<Widget> frames = new List<Widget>();

  TestProgram(Init<TArg, TModel, TMsg> init, Update<TModel, TMsg> update,
      View<TModel, TMsg> view) {
    this._program = Program.mkSimple(init, (msg, m) {
      _updateController.add(msg);
      return update(msg, m);
    }, (c, d, m) {
      _viewController.add(m);
      return view(c, d, m);
    });
  }

  void runWith(TArg arg) {
    _program.runWith(_render, arg);
  }

  void withSubscribe(Subscribe<TModel, TMsg> subscribe) {
    _program = _program.copyWith(subscribe: subscribe);
  }

  void _render(Widget app) {
    frames.add(new MaterialApp(home: app));
  }

  Stream<TMsg> get updates => _updateController.stream;
  Stream<TModel> get views => _viewController.stream;
}
