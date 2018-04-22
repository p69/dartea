library dartea;

import 'dart:async';
import 'package:flutter/widgets.dart';
import 'package:flutter/foundation.dart';
import 'package:collection/collection.dart';

part 'src/types.dart';
part 'src/cmd.dart';
part 'src/widget.dart';

/// Basic application component
class Program<TArg, TModel, TMsg> {
  final Init<TArg, TModel, TMsg> init;
  final Update<TModel, TMsg> update;
  final Subscribe<TModel, TMsg> subscribe;
  final View<TModel, TMsg> view;
  final OnError onError;

  Program(this.init, this.update, this.view,
      {Subscribe<TModel, TMsg> subscribe, OnError onError})
      : this.subscribe = subscribe ?? ((_) => const Cmd.none()),
        this.onError =
            onError ?? ((d, e) => debugPrint("Dartea program error: $d $e"));

  Widget buildWith({Key key, TArg initArg}) {
    return new DarteaWidget(this, initArg: initArg, key: key);
  }
}
