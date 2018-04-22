part of dartea;

const rootKey = const Key('dartea_root_widget');

class DarteaWidget<TArg, TModel, TMsg> extends StatefulWidget {
  final Program<TArg, TModel, TMsg> program;
  final TArg initArg;

  DarteaWidget(this.program, {this.initArg, Key key})
      : super(key: key ?? rootKey);
  @override
  State<StatefulWidget> createState() =>
      new _DrateaProgramState<TArg, TModel, TMsg>();
}

class _DrateaProgramState<TArg, TModel, TMsg>
    extends State<DarteaWidget<TArg, TModel, TMsg>>
    with WidgetsBindingObserver {
  TModel _currentModel;
  StreamController<TMsg> _controller = new StreamController();
  StreamSubscription<TMsg> _sub;

  Dispatch<TMsg> get dispatcher => (m) {
        if (!_controller.isClosed) {
          _controller.add(m);
        }
      };

  Program<TArg, TModel, TMsg> get program => widget.program;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    var initial = program.init(widget.initArg);
    var initialModel = initial.model;
    var initialEffects = new List<Sub<TMsg>>();
    initialEffects.addAll(initial.effects);
    var newModel = initialModel;

    _sub = _controller.stream.listen((msg) {
      debugPrint("Dartea program: handle message $msg.");
      try {
        var updates = program.update(msg, newModel);
        newModel = updates.model;
        if (newModel != _currentModel) {
          setState(() {
            _currentModel = newModel;
          });
        }
        for (var effect in updates.effects) {
          effect(dispatcher);
        }
      } on Exception catch (e) {
        program.onError(
            "Dartea program error: failed while processing message $msg", e);
      }
    });

    setState(() {
      _currentModel = newModel;
    });
    initialEffects.addAll(program.subscribe(newModel));
    initialEffects.forEach((effect) => effect(dispatcher));
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _sub?.cancel();
    _controller?.close();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    debugPrint("Dartea program app state chaned: $state.");
    switch (state) {
      case AppLifecycleState.inactive:
      case AppLifecycleState.paused:
      case AppLifecycleState.suspending:
        _sub?.pause();
        break;
      case AppLifecycleState.resumed:
        _sub?.resume();
    }
  }

  @override
  Widget build(BuildContext context) => _currentModel == null
      ? new Container()
      : program.view(context, dispatcher, _currentModel);
}
