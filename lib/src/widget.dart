part of dartea;

class DarteaAppWidget<TModel, TMsg> extends StatelessWidget {
  static const rootKey = const Key('dartea_root_widget');

  final TModel _model;
  final View<TModel, TMsg> _view;
  final Dispatch<TMsg> _dispatch;

  DarteaAppWidget(this._dispatch, this._view, this._model) : super(key: rootKey);

  @override
  Widget build(BuildContext context) {
    if (_model == null) {
      return new Container();
    }
    return _view(context, _dispatch, _model);
  }
}