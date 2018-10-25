library dartea;

import 'dart:async';
import 'package:async/async.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter/foundation.dart';
import 'package:collection/collection.dart';

part 'src/types.dart';
part 'src/cmd.dart';
part 'src/widget.dart';
part 'src/messages_bus.dart';

/// Container object for applcation's functions
/// [init] - creates inital state of a [TModel] type
/// [update] - handle all messages of [TMsg] type and current model.
/// Returns [Upd<TModel, TMsg>] with new model and (optionally) commands (see [Cmd] class)
/// [view] - gets [BuildContext], [Dispatch<TMsg>] and [TModel] and returns Flutter's Widgets tree.
/// [onError] - handler for all errors inside program loop
/// [subscription] - separate handler for manage subscriptions to external events.
/// Gets subscription holder of [TSub] (for example [StreamSubscription] or some custom class), [Dispatch<TMSg>] and current model.
/// Subscription handler calls after every model's changes (the same as [update] function).
/// If you need to save subscription holder then return it as a function result.
/// If subscription is disposed then just return null (or create new).
/// [lifeCycleUpd] - separate handler for global app lifecycle events.
/// Gets [AppLifeCycleState] and current model of [TModel].
/// Returns [Upd<TModel, TMsg>] with new model and (optionally) commands (see [Cmd] class).
/// It could be useful for saving state, cancelling some operation or disposing subscription.
class Program<TModel, TMsg, TSub> {
  final Init<TModel, TMsg> init;
  final Update<TModel, TMsg> update;
  final View<TModel, TMsg> view;
  final OnError onError;
  final Subscribe<TModel, TMsg, TSub> sub;
  final LifeCycleUpdate<TModel, TMsg> lifeCycleUpdate;

  Program(
    this.init,
    this.update,
    this.view, {
    Subscribe<TModel, TMsg, TSub> subscription,
    LifeCycleUpdate<TModel, TMsg> lifeCycleUpd,
    OnError onError,
  })  : this.onError =
            onError ?? ((s, e) => debugPrint('Dartea program error: $e\n$s')),
        this.sub = subscription ?? emptySub<TModel, TMsg>(),
        this.lifeCycleUpdate =
            lifeCycleUpd ?? emptyLifecycleUpdate<TModel, TMsg>();

  ///Wrap all functions with [debugPrint]
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

  ///Create widget which could be inserted into Flutter application
  Widget build({Key key, bool withMessagesBus = false}) {
    return _DarteaWrapper<TModel, TMsg, TSub>(
      key: key,
      program: this,
      withMessagesBus: withMessagesBus,
    );
  }
}

/// A [ValueKey] for saving and retrieving model from [PageStorage]
/// Add it as key for [ProgramWidget] to restore latest model
/// after widget is removed and added to the tree again.
class DarteaStorageKey<T> extends ValueKey<T> {  
  const DarteaStorageKey(T value) : super(value);
}

///Ths widget creates and builds [Program].
///It could be helpful when you want create Dartea [Program]
///right from the widget's [build] method
class ProgramWidget<TModel, TMsg, TSub> extends StatelessWidget {
  final Init<TModel, TMsg> init;
  final Update<TModel, TMsg> update;
  final View<TModel, TMsg> view;
  final OnError onError;
  final Subscribe<TModel, TMsg, TSub> sub;
  final LifeCycleUpdate<TModel, TMsg> lifeCycleUpdate;
  final bool withMessagesBus;
  final bool withDebugTrace;

  const ProgramWidget({
    Key key,
    @required this.init,
    @required this.update,
    @required this.view,
    this.onError,
    this.sub,
    this.lifeCycleUpdate,
    this.withMessagesBus = false,
    this.withDebugTrace = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Program<TModel, TMsg, TSub> program;
    if (key is DarteaStorageKey) {
      program = Program(() {
        final savedModel = PageStorage.of(context)
            .readState(context, identifier: key) as TModel;
        if (savedModel != null) {
          return Upd(savedModel);
        }
        return init();
      }, (msg, model) {
        final upd = update(msg, model);
        PageStorage.of(context).writeState(context, upd.model, identifier: key);
        return upd;
      }, view,
          onError: onError, lifeCycleUpd: lifeCycleUpdate, subscription: sub);
    } else {
      program = Program(init, update, view,
          onError: onError, lifeCycleUpd: lifeCycleUpdate, subscription: sub);
    }
    if (withDebugTrace) {
      program = program.withDebugTrace();
    }
    return program.build(withMessagesBus: withMessagesBus);
  }
}

class _DarteaWrapper<TModel, TMsg, TSub> extends StatelessWidget {
  final Program<TModel, TMsg, TSub> program;
  final bool withMessagesBus;

  const _DarteaWrapper({Key key, this.program, this.withMessagesBus = false})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DarteaWidget(
      program,
      busDispatch: DarteaMessagesBus.dispatchOf(context),
      busStream: withMessagesBus ? DarteaMessagesBus.streamOf(context) : null,
    );
  }
}
