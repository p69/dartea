part of dartea;

/// Class for contorlling side-effetcs.
class Cmd<TMsg> extends DelegatingList<Effect<TMsg>> {
  Cmd(List<Effect<TMsg>> base) : super(base);
  Cmd.ofMsg(TMsg msg) : super([(dispatch) => dispatch(msg)]);
  Cmd.ofEffect(Effect<TMsg> sub) : super([sub]);
  const Cmd.none() : super(const []);

  static Cmd<TMsg> ofAction<TMsg>(void action(),
      {TMsg onSuccess(), TMsg onError(Exception e)}) {
    return new Cmd.ofEffect((Dispatch<TMsg> disptach) async {
      try {
        action();
        if (onSuccess != null) {
          disptach(onSuccess());
        }
      } on Exception catch (e) {
        if (onError != null) {
          disptach(onError(e));
        }
      }
    });
  }

  static Cmd<TMsg> ofFutureAction<TMsg>(Future action(),
      {TMsg onSuccess(), TMsg onError(Exception e)}) {
    return new Cmd.ofEffect((disptach) async {
      try {
        await action();
        if (onSuccess != null) {
          disptach(onSuccess());
        }
      } on Exception catch (e) {
        if (onError != null) {
          disptach(onError(e));
        }
      }
    });
  }

  static Cmd<TMsg> ofFunc<TResult, TMsg>(TResult func(),
      {@required TMsg onSuccess(TResult r), TMsg onError(Exception e)}) {
    return new Cmd.ofEffect((disptach) {
      try {
        var result = func();
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
    return new Cmd.ofEffect((disptach) async {
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
