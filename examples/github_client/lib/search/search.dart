library search;

import 'package:dartea/dartea.dart';
import 'package:flutter/material.dart';
import 'package:github_client/api.dart';
import 'package:github_client/helpers/router.dart';
import 'dart:async';
import 'package:stream_transform/stream_transform.dart';
import 'package:github_client/helpers/widgets.dart';
import 'package:github_client/helpers/functions.dart';
import 'package:github_client/helpers/repository_card.dart';

part 'search_state.dart';
part 'search_widgets.dart';
part 'search_view.dart';

///Handy wrapper for [Program] or [ProgramWidget]
///We can treat it as entry point for our Search component.
///This widget is stateless, but if we want to save latest model of a component
///and then restore it when logically the same component should be added into the widgets tree,
///then we should set [DarteStorageKey] as key for this widget.
///[Dartea] uses built-in mechanism [PageStorage] for that purpose.
class SearchWidget extends StatelessWidget {
  final DarteaStorageKey darteaKey;

  const SearchWidget({Key key, this.darteaKey}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ProgramWidget(
      key: darteaKey,
      init: _init,
      update: (msg, model) =>
          _update(msg, model, Router(Navigator.of(context))),
      view: _view,
      sub: _querySubscription,
      withMessagesBus: true,
      withDebugTrace: true,
    );
  }
}

/// **** Model **** ///
class SearchModel {
  final String query;
  final List<GitHubRepository> items;
  final bool isLoading;
  final Map<String, Language> languagesMap;

  SearchModel({
    this.query,
    this.items,
    this.isLoading,
    this.languagesMap,
  });
  factory SearchModel.init() => SearchModel(
    query: '',
    items: [],
    isLoading: false,
    languagesMap: {},
  );

  SearchModel copyWith({
    String query,
    List<GitHubRepository> items,
    bool isLoading,
    final Map<String, Language> languagesMap,
  }) {
    return SearchModel(
      query: query ?? this.query,
      items: items ?? this.items,
      isLoading: isLoading ?? this.isLoading,
      languagesMap: languagesMap ?? this.languagesMap,
    );
  }
}

/// **** Messages **** ///
abstract class SearchMsg {}

class OnQueryChanged implements SearchMsg {
  final String text;
  OnQueryChanged(this.text);
}

class FetchSearchResults implements SearchMsg {}

class OnSearchResultsLoaded implements SearchMsg {
  final SearchResult result;
  OnSearchResultsLoaded(this.result);
}

class OnRepoSelectedMsg implements SearchMsg {
  final GitHubRepository repo;
  OnRepoSelectedMsg(this.repo);
}

class LoadLanguagesMap implements SearchMsg {}

class OnLanguagesMapLoaded implements SearchMsg {
  final Map<String, Language> languagesMap;
  OnLanguagesMapLoaded(this.languagesMap);
}