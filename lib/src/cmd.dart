part of dartea;

/// Class for contorlling side-effetcs.
class Cmd<TMsg> extends DelegatingList<Sub<TMsg>> {
  Cmd(List<Sub<TMsg>> base) : super(base);
  Cmd.ofMsg(TMsg msg) : super([(dispatch) => dispatch(msg)]);
  Cmd.ofSub(Sub<TMsg> sub) : super([sub]);
  const Cmd._() : super(const []);

  static const Cmd none = const Cmd._();

  static Cmd<TMsg> ofFutureFuncWithArg<TArg, TResult, TMsg>(
      Future<TResult> func(TArg a),
      TMsg onSuccess(TResult r),
      TMsg onError(Exception e),
      TArg arg) {
    return new Cmd.ofSub((disptach) async {
      try {
        var result = await func(arg);
        disptach(onSuccess(result));
      } on Exception catch (ex) {
        disptach(onError(ex));
      }
    });
  }

  static Cmd<TMsg> ofFutureFunc<TResult, TMsg>(Future<TResult> func(),
      TMsg onSuccess(TResult r), TMsg onError(Exception e)) {
    return new Cmd.ofSub((disptach) async {
      try {
        var result = await func();
        disptach(onSuccess(result));
      } on Exception catch (ex) {
        disptach(onError(ex));
      }
    });
  }

  static Cmd<TMsg> performFunc<TResult, TMsg>(
      Future<TResult> func(), TMsg onSuccess(TResult r)) {
    return new Cmd.ofSub((disptach) async {
      try {
        var result = await func();
        disptach(onSuccess(result));
      } on Exception catch (_) {}
    });
  }

  static Cmd performAction(void action()) {
    return new Cmd.ofSub((disptach) async {
      try {
        action();
      } on Exception catch (_) {}
    });
  }

  static Cmd performTask(Future task()) {
    return new Cmd.ofSub((disptach) async {
      try {
        await task();
      } on Exception catch (_) {}
    });
  }

  static Cmd<TMsg> fmap<T, TMsg>(TMsg f(T t), Cmd<T> cmd) {
    var mapped = cmd.map((dispatcher) {
      var dispatcherMapper =
          (Dispatch<TMsg> dispatch) => (T x) => dispatch(f(x));
      return (Dispatch<TMsg> d) => dispatcher(dispatcherMapper(d));
    }).toList();
    return new Cmd(mapped);
  }

  static Cmd<TMsg> batch<TMsg>(List<Cmd<TMsg>> cmds) =>
      new Cmd(cmds.expand((x) => x).toList());
}
