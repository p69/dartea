part of filter;

/// **** Init **** ///
Upd<LanguagesFilterModel, LanguagesFilterMsg> _init() {
  return Upd(
    LanguagesFilterModel.init(),
    effects: Cmd.ofMsg(LoadLanguagesList()),
  );
}

/// **** Update **** ///
Upd<LanguagesFilterModel, LanguagesFilterMsg> _update(
    LanguagesFilterMsg msg, LanguagesFilterModel model, Router router) {
  if (msg is LoadLanguagesList) {
    final fetchListCmd = Cmd.ofAsyncFunc(
      getLanguages,
      onSuccess: (x) => OnLanguagesListLoaded(x),
    );
    return Upd(model, effects: fetchListCmd);
  }
  if (msg is OnLanguagesListLoaded) {
    return Upd(model.copyWith(items: msg.langs));
  }
  if (msg is OnAllLanguagesTappedMsg) {
    return Upd(
      model.copyWith(selectedItem: _allLang),
      effects: Cmd.ofAction(router.back),
      msgsToBus: [OnLanguageFilterChanged(null)],
    );
  }
  if (msg is OnLanguagesTapped) {
    return Upd(
      model.copyWith(selectedItem: model.selectedItem == msg.lang ? _allLang : msg.lang),
      effects: Cmd.ofAction(router.back),
      msgsToBus: [OnLanguageFilterChanged(model.selectedItem == msg.lang ? null : msg.lang)],
    );
  }
  if (msg is OnPeriodTapped) {
    return Upd(
      model.copyWith(
        selectedPeriod: msg.period,
      ),
      effects: Cmd.ofAction(router.back),
      msgsToBus: [OnPeriodFilterChanged(msg.period)],
    );
  }
  return Upd(model);
}