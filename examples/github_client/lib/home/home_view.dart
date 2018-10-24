part of home;

/// **** View **** ///
Widget _view(BuildContext ctx, Dispatch<HomeMsg> dispatch, HomeModel model) {
  return Scaffold(
    appBar: AppBar(
      title: model.selectedTab == Tab.trending
          ? TrendingAppBarTitle()
          : SearchAppBarTitle(),
      actions:
      model.selectedTab == Tab.trending ? _trendingAppBarActions(ctx) : [],
    ),
    body: model.selectedTab == Tab.trending
        ? TrendingWidget(
      darteaKey: DarteaStorageKey('trending_tab_program'),
    )
        : SearchWidget(
      darteaKey: DarteaStorageKey('search_tab_program'),
    ),
    bottomNavigationBar: _bottomNavigation(ctx, dispatch, model.selectedTab),
    endDrawer: model.selectedTab == Tab.trending ? _filterView() : null,
  );
}

List<Widget> _trendingAppBarActions(BuildContext ctx) => <Widget>[
  _FilterIconButton(),
  IconButton(
    icon: Icon(Icons.refresh),
    onPressed: () => DarteaMessagesBus.dispatchOf(ctx)(LoadTrendingMsg()),
  ),
];

///It creates new [Dartea] component.
Widget _filterView() {
  return Drawer(
    child: Container(
      color: Colors.grey[200],
      child: Padding(
        padding: EdgeInsets.only(left: 10.0, right: 10.0),
        child: LanguagesFilterWidget(
          darteaKey: DarteaStorageKey('lang_filter_program'),
        ),
      ),
    ),
  );
}

class _FilterIconButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.filter_list),
      onPressed: () => Scaffold.of(context).openEndDrawer(),
    );
  }
}

Widget _bottomNavigation(
    BuildContext context, Dispatch<HomeMsg> dispatch, Tab current) {
  return BottomNavigationBar(
    currentIndex: Tab.values.indexOf(current),
    onTap: ((i) => dispatch(OnTabChangedMsg(Tab.values[i]))),
    items: Tab.values.map((tab) {
      return BottomNavigationBarItem(
        icon: Icon(
          tab == Tab.trending ? Icons.trending_up : Icons.search,
        ),
        title: Text(
          tab == Tab.trending ? 'trending' : 'search',
        ),
      );
    }).toList(),
  );
}