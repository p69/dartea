part of search;

///Create [TextEditingController] as singleton for saving and restoring text between tab switching.
///I don't know another way to set initial value for [TextEditField]
final _textEditController = TextEditingController();

class SearchAppBarTitle extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _textEditController,
      style: Theme.of(context).textTheme.title.copyWith(
        color: Colors.white,
        decoration: TextDecoration.none,
      ),
      onChanged: (txt) => _queryTextController.add(txt),
      decoration: InputDecoration(
        border: InputBorder.none,
        hintText: 'Search',
        hintStyle: Theme.of(context).textTheme.title.copyWith(
          color: Colors.white,
        ),
        icon: Icon(
          Icons.search,
          color: Colors.white,
        ),
      ),
    );
  }
}