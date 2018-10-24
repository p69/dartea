import 'package:flutter/material.dart';
import 'package:github_client/api.dart';

class NothingFoundWidget extends StatelessWidget {
  const NothingFoundWidget({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        '¯\\_(ツ)_/¯',
        style: Theme.of(context).textTheme.headline,
      ),
    );
  }
}

class LoadingIndicatorWidget extends StatelessWidget {
  const LoadingIndicatorWidget({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: CircularProgressIndicator(
        backgroundColor: Colors.pink,
      ),
    );
  }
}

class AvatarHeroWidget extends StatelessWidget {
  final GitHubRepository repository;

  const AvatarHeroWidget({Key key, this.repository}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: repository,
      child: CircleAvatar(
        backgroundImage: NetworkImage(repository.owner.avatar.toString()),
      ),
    );
  }
}
