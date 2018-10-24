library trending;

import 'package:github_client/api.dart';
import 'package:flutter/material.dart';
import 'package:dartea/dartea.dart';
import 'package:github_client/helpers/router.dart';
import 'package:github_client/helpers/repository_card.dart';
import 'package:github_client/helpers/widgets.dart';
import 'package:github_client/helpers/functions.dart';

part 'trending_state.dart';
part 'trending_view.dart';
part 'trending_widgets.dart';

///Handy wrapper for [Program] or [ProgramWidget]
///We can treat it as entry point for our Trending component.
///This widget is stateless, but if we want to save latest model of a component
///and then restore it when logically the same component should be added into the widgets tree,
///then we should set [DarteStorageKey] as key for this widget.
///[Dartea] uses built-in mechanism [PageStorage] for that purpose.
class TrendingWidget extends StatelessWidget {
  final DarteaStorageKey darteaKey;

  const TrendingWidget({Key key, this.darteaKey}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ProgramWidget(
      key: darteaKey,
      init: _initModel,
      update: (msg, model) =>
          _update(msg, model, Router(Navigator.of(context))),
      view: _view,
      withDebugTrace: true,
      withMessagesBus: true,
    );
  }
}



/// **** Model **** ///
class TrendingModel {
  final bool isLoading;
  final List<GitHubRepository> items;
  final Language languageFilter;
  final TrendingPeriod periodFilter;
  final Map<String, Language> languagesMap;

  TrendingModel({
    this.isLoading,
    this.items,
    this.languageFilter,
    this.languagesMap,
    this.periodFilter,
  });
  factory TrendingModel.init() {
    return TrendingModel(
      isLoading: false,
      items: [],
      languageFilter: null,
      languagesMap: {},
      periodFilter: TrendingPeriod.weekly,
    );
  }

  TrendingModel copyWith({
    bool isLoading,
    List<GitHubRepository> items,
    Language languageFilter,
    Map<String, Language> languagesMap,
    TrendingPeriod periodFilter,
  }) {
    return TrendingModel(
      isLoading: isLoading ?? this.isLoading,
      items: items ?? this.items,
      languageFilter: languageFilter ?? this.languageFilter,
      languagesMap: languagesMap ?? this.languagesMap,
      periodFilter: periodFilter ?? this.periodFilter,
    );
  }
}

/// **** Messages **** ///
abstract class TrendingMsg {}

class LoadTrendingMsg implements TrendingMsg {}

class OnTrendingLoadedMsg implements TrendingMsg {
  final SearchResult result;
  OnTrendingLoadedMsg(this.result);
}

class OnTrendingLoadingErrorMsg implements TrendingMsg {
  final Exception error;
  OnTrendingLoadingErrorMsg(this.error);
}

class OnRepoSelectedMsg implements TrendingMsg {
  final GitHubRepository repo;
  OnRepoSelectedMsg(this.repo);
}

class OnLanguageFilterChanged implements TrendingMsg {
  final Language lang;
  OnLanguageFilterChanged(this.lang);
}

class OnPeriodFilterChanged implements TrendingMsg {
  final TrendingPeriod period;
  OnPeriodFilterChanged(this.period);
}

class LoadLanguagesMap implements TrendingMsg {}

class OnLanguagesMapLoaded implements TrendingMsg {
  final Map<String, Language> languagesMap;
  OnLanguagesMapLoaded(this.languagesMap);
}