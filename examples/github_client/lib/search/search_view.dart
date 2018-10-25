part of search;

/// **** View **** ///
Widget _view(
    BuildContext ctx, Dispatch<SearchMsg> dispatch, SearchModel model) {
  return Container(
    child: model.isLoading
        ? LoadingIndicatorWidget()
        : _viewItemsList(ctx, dispatch, model),
  );
}

Widget _viewItemsList(
    BuildContext context, Dispatch<SearchMsg> dispatch, SearchModel model) {
  final items = model.items;
  if (items.length == 0) {
    return NothingFoundWidget();
  }
  return ListView.builder(
    key: PageStorageKey('search_list'),
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