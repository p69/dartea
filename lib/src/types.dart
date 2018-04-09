part of dartea;

typedef Dispatch<TMsg> = void Function(
    TMsg msg); //function for sending messages in runtime loop
typedef Sub<TMsg> = void Function(
    Dispatch<TMsg> dispatch); //callback for side-effects

typedef Init<TArg, TModel, TMsg> = UpdateResult<TModel, TMsg> Function(
    TArg params); //function for initializing model

typedef View<TModel, TMsg> = Widget Function(BuildContext ctx,
    Dispatch<TMsg> dispatch, TModel model); //function for rendering UI

typedef OnError = void Function(String description,
    Exception exception); //function for error handling in runtime loop

typedef Update<TModel, TMsg> = UpdateResult<TModel, TMsg> Function(
    TMsg msg, TModel model); //function for updating state(model)

typedef Subscribe<TModel, TMsg> = Cmd<TMsg> Function(
    TModel model); //function for subsrcibing on external sources

typedef RunApp = void Function(Widget root); //factory for host widget

class UpdateResult<TModel, TMsg> {
  final TModel model;
  final Cmd<TMsg> effects;
  UpdateResult(this.model, {this.effects = const Cmd.none()});
}

class UpdateChildResult<TModel, TMsg, TParentMsg> {
  final TModel model;
  final Cmd<TMsg> effects;
  final List<TParentMsg> toParent;
  UpdateChildResult(this.model,
      {this.effects = const Cmd.none(), this.toParent = const []});
}
