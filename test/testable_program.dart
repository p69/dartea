import 'dart:async';

import 'package:dartea/dartea.dart';
import 'package:flutter/material.dart';

class TestProgram<TModel, TMsg> {
  Program<TModel, TMsg, StreamSubscription<TMsg>> _program;
  final _updateController = new StreamController<TMsg>();
  final _viewController = new StreamController<TModel>();
  Widget _widget;

  TestProgram(Init<TModel, TMsg> init, Update<TModel, TMsg> update,
      View<TModel, TMsg> view,
      {Subscribe<TModel, TMsg, StreamSubscription<TMsg>> subscribe}) {
    this._program = new Program(init, (msg, m) {
      _updateController.add(msg);
      return update(msg, m);
    }, (c, d, m) {
      _viewController.add(m);
      return view(c, d, m);
    }, subscription: subscribe);
  }

  void withSubscription(Subscribe<TModel, TMsg, StreamSubscription<TMsg>> subscribe) {
    _program = new Program(_program.init, _program.update, _program.view,
        subscription: subscribe);
  }

  void run() {
    _widget = _program.build();
  }

  Widget get frame => new MaterialApp(home: _widget);

  Stream<TMsg> get updates => _updateController.stream;
  Stream<TModel> get views => _viewController.stream;
}
