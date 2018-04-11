part of dartea;

/// Class for contorlling side-effetcs.
class Cmd<TMsg> extends DelegatingList<Sub<TMsg>> {
  Cmd(List<Sub<TMsg>> base) : super(base);
  Cmd.ofMsg(TMsg msg) : super([(dispatch) => dispatch(msg)]);
  Cmd.ofSub(Sub<TMsg> sub) : super([sub]);
  const Cmd.none() : super(const []);

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

  static Cmd<TMsg> ofAction1<TMsg, TArg>(void action(TArg arg), TArg arg,
      {TMsg onError(Exception e)}) {
    return new Cmd.ofSub((Dispatch<TMsg> disptach) async {
      try {
        action(arg);
      } on Exception catch (e) {
        if (onError != null) {
          disptach(onError(e));
        }
      }
    });
  }

  static Cmd<TMsg> ofAction2<TMsg, TArg1, TArg2>(
      void action(TArg1 arg1, TArg2 arg2), TArg1 arg1, TArg2 arg2,
      {TMsg onError(Exception e)}) {
    return new Cmd.ofSub((Dispatch<TMsg> disptach) async {
      try {
        action(arg1, arg2);
      } on Exception catch (e) {
        if (onError != null) {
          disptach(onError(e));
        }
      }
    });
  }

  static Cmd<TMsg> ofAction3<TMsg, TArg1, TArg2, TArg3>(
      void action(TArg1 arg1, TArg2 arg2, TArg3 arg3),
      TArg1 arg1,
      TArg2 arg2,
      TArg3 arg3,
      {TMsg onError(Exception e)}) {
    return new Cmd.ofSub((Dispatch<TMsg> disptach) async {
      try {
        action(arg1, arg2, arg3);
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

  static Cmd<TMsg> ofFutureAction1<TMsg, TArg>(
      Future action(TArg arg), TArg arg,
      {TMsg onError(Exception e)}) {
    return new Cmd.ofSub((disptach) async {
      try {
        await action(arg);
      } on Exception catch (e) {
        if (onError != null) {
          disptach(onError(e));
        }
      }
    });
  }

  static Cmd<TMsg> ofFutureAction2<TMsg, TArg1, TArg2>(
      Future action(TArg1 arg1, TArg2 arg2), TArg1 arg1, TArg2 arg2,
      {TMsg onError(Exception e)}) {
    return new Cmd.ofSub((disptach) async {
      try {
        await action(arg1, arg2);
      } on Exception catch (e) {
        if (onError != null) {
          disptach(onError(e));
        }
      }
    });
  }

  static Cmd<TMsg> ofFutureAction3<TMsg, TArg1, TArg2, TArg3>(
      Future action(TArg1 arg1, TArg2 arg2, TArg3 arg3),
      TArg1 arg1,
      TArg2 arg2,
      TArg3 arg3,
      {TMsg onError(Exception e)}) {
    return new Cmd.ofSub((disptach) async {
      try {
        await action(arg1, arg2, arg3);
      } on Exception catch (e) {
        if (onError != null) {
          disptach(onError(e));
        }
      }
    });
  }

  static Cmd<TMsg> ofFunc<TResult, TMsg>(TResult func(),
      {@required TMsg onSuccess(TResult r), TMsg onError(Exception e)}) {
    return new Cmd.ofSub((disptach) {
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

  static Cmd<TMsg> ofFunc1<TResult, TMsg, TArg>(
      TResult func(TArg arg), TArg arg,
      {@required TMsg onSuccess(TResult r), TMsg onError(Exception e)}) {
    return new Cmd.ofSub((disptach) {
      try {
        var result = func(arg);
        disptach(onSuccess(result));
      } on Exception catch (ex) {
        if (onError != null) {
          disptach(onError(ex));
        }
      }
    });
  }

  static Cmd<TMsg> ofFunc2<TResult, TMsg, TArg1, TArg2>(
      TResult func(TArg1 arg1, TArg2 arg2), TArg1 arg1, TArg2 arg2,
      {@required TMsg onSuccess(TResult r), TMsg onError(Exception e)}) {
    return new Cmd.ofSub((disptach) {
      try {
        var result = func(arg1, arg2);
        disptach(onSuccess(result));
      } on Exception catch (ex) {
        if (onError != null) {
          disptach(onError(ex));
        }
      }
    });
  }

  static Cmd<TMsg> ofFunc3<TResult, TMsg, TArg1, TArg2, TArg3>(
      TResult func(TArg1 arg1, TArg2 arg2, TArg3 arg3),
      TArg1 arg1,
      TArg2 arg2,
      TArg3 arg3,
      {@required TMsg onSuccess(TResult r),
      TMsg onError(Exception e)}) {
    return new Cmd.ofSub((disptach) {
      try {
        var result = func(arg1, arg2, arg3);
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

  static Cmd<TMsg> ofFutureFunc1<TResult, TMsg, TArg>(
      Future<TResult> func(TArg arg), TArg arg,
      {@required TMsg onSuccess(TResult r), TMsg onError(Exception e)}) {
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

  static Cmd<TMsg> ofFutureFunc2<TResult, TMsg, TArg1, TArg2>(
      Future<TResult> func(TArg1 arg1, TArg2 arg2), TArg1 arg1, TArg2 arg2,
      {@required TMsg onSuccess(TResult r), TMsg onError(Exception e)}) {
    return new Cmd.ofSub((disptach) async {
      try {
        var result = await func(arg1, arg2);
        disptach(onSuccess(result));
      } on Exception catch (ex) {
        if (onError != null) {
          disptach(onError(ex));
        }
      }
    });
  }

  static Cmd<TMsg> ofFutureFunc3<TResult, TMsg, TArg1, TArg2, TArg3>(
      Future<TResult> func(TArg1 arg1, TArg2 arg2, TArg3 arg3),
      TArg1 arg1,
      TArg2 arg2,
      TArg3 arg3,
      {@required TMsg onSuccess(TResult r),
      TMsg onError(Exception e)}) {
    return new Cmd.ofSub((disptach) async {
      try {
        var result = await func(arg1, arg2, arg3);
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