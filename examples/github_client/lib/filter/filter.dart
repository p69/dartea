library filter;

import 'package:dartea/dartea.dart';
import 'package:flutter/material.dart';
import 'package:github_client/api.dart';
import 'package:github_client/helpers/router.dart';
import 'package:github_client/trending/trending.dart';

part 'filter_state.dart';
part 'filter_view.dart';

class LanguagesFilterWidget extends StatelessWidget {
  final DarteaStorageKey darteaKey;

  const LanguagesFilterWidget({Key key, this.darteaKey}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ProgramWidget(
      key: darteaKey,
      init: _init,
      update: (msg, model) =>
          _update(msg, model, Router(Navigator.of(context))),
      view: _view,
      withDebugTrace: true,
    );
  }
}

/// **** Model **** ///

final _allLang = Language(name: 'all', displayName: 'all', color: 0xFFFFFFFF);

class LanguagesFilterModel {
  final List<Language> items;
  final Language selectedItem;
  final TrendingPeriod selectedPeriod;

  LanguagesFilterModel({this.items, this.selectedItem, this.selectedPeriod});

  factory LanguagesFilterModel.init() => LanguagesFilterModel(
      items: [], selectedItem: _allLang, selectedPeriod: TrendingPeriod.weekly);

  LanguagesFilterModel copyWith(
      {List<Language> items,
        Language selectedItem,
        TrendingPeriod selectedPeriod}) {
    return LanguagesFilterModel(
      items: items ?? this.items,
      selectedItem: selectedItem ?? this.selectedItem,
      selectedPeriod: selectedPeriod ?? this.selectedPeriod,
    );
  }
}

/// **** Messages **** ///
abstract class LanguagesFilterMsg {}

class LoadLanguagesList implements LanguagesFilterMsg {}

class OnLanguagesListLoaded implements LanguagesFilterMsg {
  final List<Language> langs;
  OnLanguagesListLoaded(this.langs);
}

class OnLanguagesTapped implements LanguagesFilterMsg {
  final Language lang;
  OnLanguagesTapped(this.lang);
}

class OnAllLanguagesTappedMsg implements LanguagesFilterMsg {}

class OnPeriodTapped implements LanguagesFilterMsg {
  final TrendingPeriod period;
  OnPeriodTapped(this.period);
}