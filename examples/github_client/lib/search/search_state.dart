part of search;

/// **** Init **** ///
Upd<SearchModel, SearchMsg> _init() => Upd<SearchModel, SearchMsg>(
  SearchModel.init(),
  effects: Cmd.ofAsyncFunc(getLanguagesByNameMap,
      onSuccess: (x) => OnLanguagesMapLoaded(x)),
);

/// **** Update **** ///
Upd<SearchModel, SearchMsg> _update(
    SearchMsg msg, SearchModel model, Router router) {
  if (msg is OnQueryChanged) {
    final newModel = model.copyWith(query: msg.text);
    if (msg.text.isNotEmpty) {
      return Upd(
        newModel,
        effects: Cmd.ofMsg(FetchSearchResults()),
      );
    }
    return Upd(newModel);
  }
  if (msg is FetchSearchResults) {
    final fetchCmd = Cmd.ofAsyncFunc(
          () => fetchReposByQuery(model.query),
      onSuccess: (res) => OnSearchResultsLoaded(res),
      onError: (_) => OnSearchResultsLoaded(null),
    );
    return Upd(model.copyWith(isLoading: true), effects: fetchCmd);
  }
  if (msg is OnSearchResultsLoaded) {
    if (msg.result == null) {
      return Upd(model.copyWith(isLoading: false, items: []));
    }
    return Upd(model.copyWith(isLoading: false, items: msg.result.items));
  }
  if (msg is OnRepoSelectedMsg) {
    return Upd(
      model,
      effects: Cmd.ofAction(() => router.showDetailsFor(repo: msg.repo)),
    );
  }
  if (msg is LoadLanguagesMap) {
    final cmd = Cmd.ofAsyncFunc(getLanguagesByNameMap,
        onSuccess: (res) => OnLanguagesMapLoaded(res));
    return Upd(model, effects: cmd);
  }
  if (msg is OnLanguagesMapLoaded) {
    return Upd(model.copyWith(languagesMap: msg.languagesMap));
  }
  return Upd(model);
}

/// **** Subscription **** ///

///Use this [StreamController] as external source of query changes
StreamController<String> _queryTextController = StreamController.broadcast();

///This function is called on every model update.
///We keep our subscription open until our [DarteaWidget] is alive.
///When [DarteWidget] is getting dispose this function is called last time with [model=null]
StreamSubscription<String> _querySubscription(StreamSubscription<String> sub,
    Dispatch<SearchMsg> dispatch, SearchModel model) {
  if (model == null) {
    sub?.cancel();
    return null;
  }
  if (sub != null) {
    return sub;
  }
  sub = _queryTextController.stream
      .transform(debounce(const Duration(milliseconds: 600)))
      .listen((txt) => dispatch(OnQueryChanged(txt)));
  return sub;
}