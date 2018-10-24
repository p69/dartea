import 'package:flutter/material.dart';
import 'package:github_client/api.dart';
import 'package:github_client/helpers/widgets.dart';

class RepositoryCard extends StatelessWidget {
  final VoidCallback onPressed;
  final GitHubRepository repo;
  final Color languageColor;

  const RepositoryCard({
    Key key,
    @required this.repo,
    this.onPressed,
    this.languageColor = Colors.black,
  }) : super(key: key);

  @override
  Widget build(BuildContext ctx) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 5.0, horizontal: 10.0),
      child: MaterialButton(
        onPressed: onPressed,
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 10.0),
          child: Row(
            mainAxisSize: MainAxisSize.max,
            children: [
              AvatarHeroWidget(
                repository: repo,
              ),
              SizedBox(
                width: 10.0,
              ),
              Flexible(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      repo.fullName,
                      maxLines: 1,
                      style: Theme.of(ctx).textTheme.subhead.copyWith(
                          fontWeight: FontWeight.w500, color: Colors.black),
                    ),
                    SizedBox(
                      height: 10.0,
                    ),
                    Text(
                      repo.description ?? '',
                      style: Theme.of(ctx)
                          .textTheme
                          .body1
                          .copyWith(color: Colors.black),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 5,
                    ),
                    SizedBox(
                      height: 10.0,
                    ),
                    _viewRepoStats(ctx, repo, languageColor),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Widget _viewRepoStats(
    BuildContext ctx, GitHubRepository repo, Color languageColor) {
  return Row(
    children: <Widget>[
      _viewRepoStatsItem(ctx, '${repo.stargazersCount}', Icons.star_border),
      SizedBox(
        width: 10.0,
      ),
      _viewRepoStatsItem(ctx, '${repo.forksCount}', Icons.repeat),
      SizedBox(
        width: 10.0,
      ),
      _viewRepoStatsItem(ctx, repo.language ?? 'N/\A', Icons.language,
          color: languageColor),
    ],
  );
}

Widget _viewRepoStatsItem(BuildContext ctx, String value, IconData icon,
    {Color color: Colors.black}) {
  return Row(
    children: <Widget>[
      Icon(
        icon,
        size: 18.0,
        color: color,
      ),
      SizedBox(
        width: 5.0,
      ),
      Text(
        value,
        style: Theme.of(ctx).textTheme.body2.copyWith(color: color),
      ),
    ],
  );
}
