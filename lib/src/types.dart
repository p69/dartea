part of dartea;

/// function for sending messages into the program loop
typedef Dispatch<TMsg> = void Function(TMsg msg);

/// callback for side-effects
typedef Sub<TMsg> = void Function(Dispatch<TMsg> dispatch);

/// function for initializing model
typedef Init<TArg, TModel, TMsg> = Upd<TModel, TMsg> Function(TArg params);

/// function for creating widgets tree
typedef View<TModel, TMsg> = Widget Function(
    BuildContext ctx, Dispatch<TMsg> dispatch, TModel model);

/// function for error handling in runtime loop
typedef OnError = void Function(String description, Exception exception);

/// function for updating state(model)
typedef Update<TModel, TMsg> = Upd<TModel, TMsg> Function(
    TMsg msg, TModel model);

/// function for subsrcibing on external sources
typedef Subscribe<TModel, TMsg> = Cmd<TMsg> Function(TModel model);

/// function for render created widgets tree (typicaly through runApp)
typedef RenderView = void Function(Widget root);

/// Simple tuple of Model*Cmds (for init or update functions)
class Upd<TModel, TMsg> {
  final TModel model;
  final Cmd<TMsg> effects;
  Upd(this.model, {this.effects = const Cmd.none()});
}

/// The same as [Upd] but with addional messages for communication child with parent
class UpdChild<TModel, TMsg, TParentMsg> {
  final TModel model;
  final Cmd<TMsg> effects;
  final List<TParentMsg> toParent;
  UpdChild(this.model,
      {this.effects = const Cmd.none(), this.toParent = const []});
}
