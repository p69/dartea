library dartea;

import 'dart:async';
import 'package:async/async.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter/foundation.dart';
import 'package:collection/collection.dart';

part 'src/types.dart';
part 'src/cmd.dart';
part 'src/widget.dart';

/// Container object for applcation's functions
class Program<TModel, TMsg, TSub> {
  final Init<TModel, TMsg> init;
  final Update<TModel, TMsg> update;
  final View<TModel, TMsg> view;
  final OnError onError;
  final Subscribe<TModel, TMsg, TSub> sub;
  final LifeCycleUpdate<TModel, TMsg> lifeCycleUpdate;

  Program(this.init, this.update, this.view,
      {Subscribe<TModel, TMsg, TSub> subscription,
      LifeCycleUpdate<TModel, TMsg> lifeCycleUpd,
      OnError onError})
      : this.onError =
            onError ?? ((s, e) => debugPrint('Dartea program error: $e\n$s')),
        this.sub = subscription ?? ((_, __, ___) => null),
        this.lifeCycleUpdate =
            lifeCycleUpd != null ? lifeCycleUpd : ((_, m) => Upd(m));

  ///wrap all functions with [debugPrint]
  Program<TModel, TMsg, TSub> withDebugTrace() {
    return Program(
        () {
          debugPrint('Dartea program init');
          final res = init();
          debugPrint('Dartea program inited: ${res.model}');
          return res;
        },
        (msg, m) {
          debugPrint('Dartea handle message $msg. Current state is $m');
          final res = update(msg, m);
          debugPrint('Dartea updated state is ${res.model}');
          return res;
        },
        view,
        subscription: (s, d, m) {
          debugPrint('Dartea subscribe current sub:$s, model:$m');
          final res = sub(s, d, m);
          debugPrint('Dartea subscribe new sub:$res, model:$m');
          return res;
        },
        lifeCycleUpd: (s, m) {
          debugPrint('Dartea app state cahnged state:$s, current model:$m');
          final res = lifeCycleUpdate(s, m);
          debugPrint('Dartea app state cahnged state:$s, updated model:$m');
          return res;
        },
        onError: onError);
  }

  ///Create widget chich could be inserted into Flutter application
  Widget build({Key key}) {
    return new DarteaWidget(this, key: key);
  }
}
