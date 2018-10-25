library home;

import 'package:dartea/dartea.dart';
import 'package:flutter/material.dart';
import 'package:github_client/filter/filter.dart';
import 'package:github_client/search/search.dart';
import 'package:github_client/trending/trending.dart';

part 'home_view.dart';

///Handy wrapper for [Program] or [ProgramWidget]
///We can treat it as entry point for our Home component.
class HomeWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ProgramWidget(
      init: () => Upd<HomeModel, HomeMsg>(HomeModel.init()),
      update: _update,
      view: _view,
      withDebugTrace: true,
    );
  }
}

enum Tab { trending, search }

/// **** Model **** ///
class HomeModel {
  final Tab selectedTab;

  HomeModel({this.selectedTab});

  factory HomeModel.init() => HomeModel(selectedTab: Tab.trending);
}

/// **** Messages **** ///
abstract class HomeMsg {}

class OnTabChangedMsg implements HomeMsg {
  final Tab tab;
  OnTabChangedMsg(this.tab);
}

/// **** Update **** ///
Upd<HomeModel, HomeMsg> _update(HomeMsg msg, HomeModel model) {
  if (msg is OnTabChangedMsg) {
    return Upd(HomeModel(selectedTab: msg.tab));
  }
  return Upd(model);
}
