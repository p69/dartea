import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:github_client/api.dart';
import 'package:github_client/helpers/widgets.dart';

class RepositoryDetailsWidget extends StatelessWidget {
  final GitHubRepository repo;

  const RepositoryDetailsWidget({Key key, this.repo}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.max,
          children: [
            SizedBox(
              width: 250.0,
              child: Text(
                repo.fullName,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context)
                    .textTheme
                    .title
                    .copyWith(color: Colors.white),
              ),
            ),
            SizedBox(
              width: 10.0,
            ),
            AvatarHeroWidget(
              repository: repo,
            ),
          ],
        ),
      ),
      body: FutureBuilder<String>(
        builder: (_, snapshot) {
          if (snapshot.data == null) {
            return LoadingIndicatorWidget();
          }
          if (snapshot.data.isEmpty) {
            return NothingFoundWidget();
          }
          return Markdown(
            data: snapshot.data,
          );
        },
        initialData: null,
        future: fetchReadmeFor(repo),
      ),
    );
  }
}
