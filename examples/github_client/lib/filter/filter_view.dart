part of filter;

/// **** View **** ///
Widget _view(BuildContext ctx, Dispatch<LanguagesFilterMsg> dispatch,
    LanguagesFilterModel model) {
  final allChip = FilterChip(
    label: Text('All'),
    onSelected: (_) => dispatch(OnAllLanguagesTappedMsg()),
    backgroundColor: Colors.white,
    selectedColor: Colors.white,
    selected: model.selectedItem == _allLang,
  );

  final langChips = model.items
      .map((x) => _languageChip(dispatch, x, model))
      .toList(growable: false);

  final periodChips = TrendingPeriod.values
      .map((x) => _periodChip(dispatch, x, model))
      .toList(growable: false);

  return Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: <Widget>[
      SizedBox(
        height: 40.0,
      ),
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: periodChips,
      ),
      SizedBox(
        height: 15.0,
      ),
      Align(
        child: allChip,
        alignment: Alignment.centerLeft,
      ),
      //allChip,
      Wrap(
        spacing: 5.0,
        children: langChips,
      ),
    ],
  );
}

Widget _languageChip(Dispatch<LanguagesFilterMsg> dispatch, Language lang,
    LanguagesFilterModel model) {
  return FilterChip(
    label: Text(lang.displayName),
    onSelected: (_) => dispatch(OnLanguagesTapped(lang)),
    backgroundColor: Color(lang.color).withAlpha(80),
    selectedColor: Color(lang.color),
    disabledColor: Color(lang.color).withAlpha(30),
    selected: model.selectedItem == lang,
  );
}

String _periodToLabel(TrendingPeriod period) {
  switch (period) {
    case TrendingPeriod.daily:
      return 'Dayly';
    case TrendingPeriod.weekly:
      return 'Weekly';
    case TrendingPeriod.monthly:
      return 'Monthly';
  }
  return '';
}

Widget _periodChip(Dispatch<LanguagesFilterMsg> dispatch, TrendingPeriod period,
    LanguagesFilterModel model) {
  return ChoiceChip(
    label: Text(_periodToLabel(period)),
    selected: model.selectedPeriod == period,
    onSelected: (_) => dispatch(OnPeriodTapped(period)),
  );
}
