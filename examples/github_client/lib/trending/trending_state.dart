part of trending;

/// **** Init **** ///
Upd<TrendingModel, TrendingMsg> _initModel() => Upd(TrendingModel.init(),
    effects: Cmd.batch(
        [Cmd.ofMsg(LoadLanguagesMap()), Cmd.ofMsg(LoadTrendingMsg())]));

/// **** Update **** ///
Upd<TrendingModel, TrendingMsg> _update(
    TrendingMsg msg, TrendingModel model, Router router) {
  if (msg is LoadTrendingMsg) {
    final newModel = model.copyWith(isLoading: true);
    final loadCmd = Cmd.ofAsyncFunc(
            () => fetchTrendingRepos(forLanguage: model.languageFilter),
        onSuccess: (res) => OnTrendingLoadedMsg(res),
        onError: (e) => OnTrendingLoadingErrorMsg(e));
    return Upd(newModel, effects: loadCmd);
  }
  if (msg is OnTrendingLoadedMsg) {
    final newModel = model.copyWith(
      isLoading: false,
      items: msg.result.items ?? [],
    );
    return Upd(newModel);
  }
  if (msg is OnTrendingLoadingErrorMsg) {
    return Upd(model.copyWith(isLoading: false));
  }
  if (msg is OnRepoSelectedMsg) {
    return Upd(
      model,
      effects: Cmd.ofAction(() => router.showDetailsFor(repo: msg.repo)),
    );
  }
  if (msg is OnLanguageFilterChanged) {
    return Upd(
      model.copyWith(languageFilter: msg.lang),
      effects: Cmd.ofMsg(LoadTrendingMsg()),
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
  if (msg is OnPeriodFilterChanged) {
    return Upd(
      model.copyWith(periodFilter: msg.period),
      effects: Cmd.ofMsg(LoadTrendingMsg()),
    );
  }
  return Upd(model);
}