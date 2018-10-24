part of trending;

/// **** View **** ///
Widget _view(
    BuildContext ctx, Dispatch<TrendingMsg> dispatch, TrendingModel model) {
  return Container(
    child: model.isLoading
        ? LoadingIndicatorWidget()
        : _viewItemsList(ctx, dispatch, model),
  );
}

Widget _viewItemsList(
    BuildContext ctx, Dispatch<TrendingMsg> dispatch, TrendingModel model) {
  final items = model.items;
  if (items.length == 0) {
    return NothingFoundWidget();
  }
  return ListView.builder(
    key: PageStorageKey('trending_list'),
    itemCount: items.length,
    itemBuilder: (ctx, i) {
      final repo = items[i];
      return RepositoryCard(
        key: Key(repo.id.toString()),
        repo: repo,
        onPressed: () => dispatch(OnRepoSelectedMsg(repo)),
        languageColor: getLanguageColor(repo.language, model.languagesMap),
      );
    },
  );
}