part of dartea;

/// Class for contorlling side-effetcs.
class Cmd<TMsg> extends DelegatingList<Sub<TMsg>> {
  Cmd(List<Sub<TMsg>> base) : super(base);
  Cmd.ofMsg(TMsg msg) : super([(dispatch) => dispatch(msg)]);
  Cmd.ofSub(Sub<TMsg> sub) : super([sub]);
  const Cmd.none() : super(const []);

  static Cmd<TMsg> ofFutureFuncWithArg<TArg, TResult, TMsg>(
      Future<TResult> func(TArg a),
      {@required TMsg onSuccess(TResult r),
      TMsg onError(Exception e),
      @required TArg arg}) {
    return new Cmd.ofSub((disptach) async {
      try {
        var result = await func(arg);
        disptach(onSuccess(result));
      } on Exception catch (ex) {
        if (onError != null) {
          disptach(onError(ex));
        }
      }
    });
  }

  static Cmd<TMsg> ofFutureFunc<TResult, TMsg>(Future<TResult> func(),
      {@required TMsg onSuccess(TResult r), TMsg onError(Exception e)}) {
    return new Cmd.ofSub((disptach) async {
      try {
        var result = await func();
        disptach(onSuccess(result));
      } on Exception catch (ex) {
        if (onError != null) {
          disptach(onError(ex));
        }
      }
    });
  }

  static Cmd<TMsg> ofAction<TMsg>(void action(), {TMsg onError(Exception e)}) {
    return new Cmd.ofSub((Dispatch<TMsg> disptach) async {
      try {
        action();
      } on Exception catch (e) {
        if (onError != null) {
          disptach(onError(e));
        }
      }
    });
  }

  static Cmd<TMsg> ofFutureAction<TMsg>(Future action(),
      {TMsg onError(Exception e)}) {
    return new Cmd.ofSub((disptach) async {
      try {
        await action();
      } on Exception catch (e) {
        if (onError != null) {
          disptach(onError(e));
        }
      }
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
