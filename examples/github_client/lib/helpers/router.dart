import 'package:flutter/material.dart';
import 'package:github_client/api.dart';
import 'package:github_client/details/details.dart';

class Router {
  final NavigatorState _navigator;
  Router(this._navigator);

  void showDetailsFor({GitHubRepository repo}) {
    _navigator.push(MaterialPageRoute(
        builder: (_) => RepositoryDetailsWidget(
              repo: repo,
            )));
  }

  void back() {
    _navigator.pop();
  }
}
